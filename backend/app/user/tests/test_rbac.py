"""
Tests for role-based access control: roles in the database with
permissions per function (D15), checked by a single mechanism (D16).
"""
from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import URLPattern, URLResolver, get_resolver, reverse
from rest_framework import permissions, status
from rest_framework.test import APIClient

from core.models import (LAB_ADMIN, LAB_ASSIST, SEC_ADMIN, Permission, Role,
                         SecurityEvent, logIn, roleNames)
from core.permissions import RolePermission
from core.rbac import DEFAULT_ROLES, PERMISSIONS

PASSWORD = 'Testpass123#Testpass123#'
ROLES_URL = reverse('user:role-list')
PERMISSIONS_URL = reverse('user:permissions')
MANAGE_URL = reverse('user:manage')
CREATE_URL = reverse('user:create')
ME_URL = reverse('user:me')
ITEMS_URL = '/item/items/'
LOANS_URL = '/loan/loan/'

Users = get_user_model().objects

# Las únicas vistas que no pasan por RolePermission: el catálogo público,
# el inicio de sesión, los enlaces de contraseña, la verificación de estado
# y la documentación de la API.
PUBLIC_VIEWS = {
    'ListBrandsView', 'ListCategoriesView', 'ListItemsView',
    'CreateTokenView', 'PasswordLinkCheckView', 'PasswordLinkUseView',
    'HealthCheck', 'SpectacularAPIView', 'SpectacularSwaggerView',
}


def role_url(role):
    return reverse('user:role-detail', args=[role.id])


def client_for(user):
    """Return an API client logged in as the user."""
    client = APIClient()
    client.force_authenticate(user=user)
    logIn(user)
    return client


def api_views(patterns=None):
    """Every DRF view class reachable from the URL configuration."""
    if patterns is None:
        patterns = get_resolver().url_patterns
    for pattern in patterns:
        if isinstance(pattern, URLResolver):
            yield from api_views(pattern.url_patterns)
        elif isinstance(pattern, URLPattern):
            view = getattr(pattern.callback, 'cls', None)
            if view is not None:
                yield view


class SingleMechanismTests(TestCase):
    """Test every view goes through the same permission check (D16)."""

    def test_every_view_declares_its_permission(self):
        """Test each API view either declares the permission it requires
        or is one of the known public views."""
        for view in set(api_views()):
            with self.subTest(view=view.__name__):
                if view.__name__ in PUBLIC_VIEWS:
                    self.assertEqual(list(view.permission_classes),
                                     [permissions.AllowAny])
                else:
                    self.assertEqual(list(view.permission_classes),
                                     [RolePermission])
                    self.assertIsNotNone(
                        getattr(view, 'required_permission', None))

    def test_declared_permissions_exist(self):
        """Test views only require permissions of the catalog."""
        catalog = {codename for codename, _, _ in PERMISSIONS}
        catalog.add('autenticado')
        for view in set(api_views()):
            required = getattr(view, 'required_permission', None)
            if required is None:
                continue
            values = (required.values() if isinstance(required, dict)
                      else [required])
            for value in values:
                with self.subTest(view=view.__name__):
                    self.assertIn(value, catalog)

    def test_catalog_and_default_roles_created(self):
        """Test migrating creates the catalog and the default roles."""
        self.assertEqual(
            set(Permission.objects.values_list('codename', flat=True)),
            {codename for codename, _, _ in PERMISSIONS})
        for name, data in DEFAULT_ROLES.items():
            with self.subTest(role=name):
                role = Role.objects.get(name=name)
                self.assertEqual(
                    set(role.permissions.values_list('codename', flat=True)),
                    set(data['permissions']))
        self.assertTrue(Role.objects.get(name=SEC_ADMIN).protected)


class PermissionCheckTests(TestCase):
    """Test access follows the role's permissions, not its name."""

    def setUp(self):
        self.user = Users.create_lab_assistant(
            email='ast@example.com', password=PASSWORD,
            nombres='Ana', apellido_paterno='López')
        self.client = client_for(self.user)

    def test_permission_change_applies_on_next_request(self):
        """Test giving and removing a permission to a role changes what
        its users can do, without touching the users."""
        role = Role.objects.get(name=LAB_ASSIST)
        inventory = Permission.objects.get(codename='gestionar_inventario')

        self.assertEqual(self.client.get(ITEMS_URL).status_code,
                         status.HTTP_403_FORBIDDEN)
        role.permissions.add(inventory)
        self.assertEqual(self.client.get(ITEMS_URL).status_code,
                         status.HTTP_200_OK)
        role.permissions.remove(inventory)
        self.assertEqual(self.client.get(ITEMS_URL).status_code,
                         status.HTTP_403_FORBIDDEN)

    def test_several_roles_add_up(self):
        """Test a user with several roles has all their permissions."""
        stock = Role.objects.create(name='Inventario')
        stock.permissions.add(
            Permission.objects.get(codename='gestionar_inventario'))
        self.user.roles.add(stock)

        self.assertEqual(self.client.get(ITEMS_URL).status_code,
                         status.HTTP_200_OK)
        self.assertEqual(self.client.get(LOANS_URL).status_code,
                         status.HTTP_200_OK)

    def test_user_without_roles(self):
        """Test a user without roles only reaches its own profile."""
        self.user.roles.clear()

        self.assertEqual(self.client.get(ME_URL).status_code,
                         status.HTTP_200_OK)
        self.assertEqual(self.client.get(LOANS_URL).status_code,
                         status.HTTP_403_FORBIDDEN)

    def test_profile_lists_permissions(self):
        """Test the profile tells the app what the user may do."""
        res = self.client.get(ME_URL)

        self.assertEqual(res.data['roles'], [LAB_ASSIST])
        self.assertEqual(res.data['permissions'], ['registrar_prestamos'])

    def test_denied_request_recorded(self):
        """Test a request without the permission is logged (D28)."""
        self.client.get(ITEMS_URL)

        event = SecurityEvent.objects.filter(
            event_type=SecurityEvent.ACCESS_DENIED).first()
        self.assertEqual(event.actor, self.user)
        self.assertEqual(event.detail['ruta'], ITEMS_URL)


class RoleManagementTests(TestCase):
    """Test the security admin manages roles from the API (D15)."""

    def setUp(self):
        self.security_admin = Users.create_security_admin(
            email='seg@example.com', password=PASSWORD,
            nombres='Juan', apellido_paterno='Pérez')
        self.lab_admin = Users.create_lab_admin(
            email='lab@example.com', password=PASSWORD,
            nombres='María', apellido_paterno='Quispe')
        self.client = client_for(self.security_admin)

    def test_list_roles_and_permissions(self):
        """Test the security admin sees roles and the catalog."""
        res = self.client.get(ROLES_URL)

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        names = [role['name'] for role in res.data]
        self.assertEqual(names, sorted([SEC_ADMIN, LAB_ADMIN, LAB_ASSIST]))
        lab_admin = next(r for r in res.data if r['name'] == LAB_ADMIN)
        self.assertEqual(lab_admin['user_count'], 1)
        self.assertEqual(lab_admin['area'], 'laboratorio')

        res = self.client.get(PERMISSIONS_URL)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(len(res.data), len(PERMISSIONS))

    def test_create_update_delete_role(self):
        """Test the full life of a role, recorded in the event log."""
        res = self.client.post(ROLES_URL, {
            'name': 'Inventario', 'description': 'Solo equipos',
            'permissions': ['gestionar_inventario']}, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        role = Role.objects.get(name='Inventario')

        res = self.client.patch(role_url(role), {
            'permissions': ['gestionar_inventario', 'registrar_prestamos']},
            format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(
            sorted(role.permissions.values_list('codename', flat=True)),
            ['gestionar_inventario', 'registrar_prestamos'])

        res = self.client.delete(role_url(role))
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Role.objects.filter(name='Inventario').exists())

        events = list(SecurityEvent.objects.filter(
            event_type__in=[SecurityEvent.ROLE_CREATED,
                            SecurityEvent.ROLE_UPDATED,
                            SecurityEvent.ROLE_DELETED],
        ).order_by('id'))
        self.assertEqual([e.event_type for e in events], [
            SecurityEvent.ROLE_CREATED, SecurityEvent.ROLE_UPDATED,
            SecurityEvent.ROLE_DELETED])
        self.assertEqual(events[1].detail['cambios']['permisos'], [
            ['gestionar_inventario'],
            ['gestionar_inventario', 'registrar_prestamos']])

    def test_duplicate_name_rejected(self):
        """Test role names are unique, ignoring case."""
        res = self.client.post(ROLES_URL, {
            'name': 'administradorlaboratorio', 'permissions': []},
            format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('name', res.data)

    def test_role_cannot_mix_areas(self):
        """Test a role cannot have security and lab permissions (D18)."""
        res = self.client.post(ROLES_URL, {
            'name': 'Mixto',
            'permissions': ['ver_usuarios', 'gestionar_inventario']},
            format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(Role.objects.filter(name='Mixto').exists())

    def test_role_with_users_cannot_gain_security_permissions(self):
        """Test editing a role cannot hand security permissions to the
        accounts that already have it (D18)."""
        empty = Role.objects.create(name='Vacío')
        self.lab_admin.roles.add(empty)

        res = self.client.patch(role_url(empty), {
            'permissions': ['ver_usuarios']}, format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(empty.permissions.exists())

    def test_protected_role_cannot_change(self):
        """Test the security admin role cannot be edited or deleted
        (D27)."""
        role = Role.objects.get(name=SEC_ADMIN)

        res = self.client.patch(role_url(role), {'permissions': []},
                                format='json')
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        res = self.client.delete(role_url(role))
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(role.permissions.count(),
                         len(DEFAULT_ROLES[SEC_ADMIN]['permissions']))

    def test_role_with_users_cannot_be_deleted(self):
        """Test deleting a role with users fails, keeping the users."""
        role = Role.objects.get(name=LAB_ADMIN)

        res = self.client.delete(role_url(role))

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(roleNames(self.lab_admin), [LAB_ADMIN])

    def test_lab_admin_cannot_manage_roles(self):
        """Test roles are managed only with the security permissions."""
        client = client_for(self.lab_admin)
        role = Role.objects.get(name=LAB_ASSIST)

        requests = {
            'list': lambda: client.get(ROLES_URL),
            'permissions': lambda: client.get(PERMISSIONS_URL),
            'create': lambda: client.post(ROLES_URL, {'name': 'X'}),
            'update': lambda: client.patch(role_url(role), {'name': 'X'}),
            'delete': lambda: client.delete(role_url(role)),
        }
        for name, request in requests.items():
            with self.subTest(endpoint=name):
                self.assertEqual(request().status_code,
                                 status.HTTP_403_FORBIDDEN)
        self.assertTrue(Role.objects.filter(name=LAB_ASSIST).exists())

    def test_read_only_role_can_list_but_not_change(self):
        """Test ver_roles and gestionar_roles are separate permissions."""
        auditor_role = Role.objects.create(name='Auditor')
        auditor_role.permissions.add(
            Permission.objects.get(codename='ver_roles'))
        auditor = Users.create_with_roles(
            'aud@example.com', PASSWORD, [auditor_role],
            nombres='Rosa', apellido_paterno='Mamani')
        client = client_for(auditor)

        self.assertEqual(client.get(ROLES_URL).status_code,
                         status.HTTP_200_OK)
        self.assertEqual(client.post(ROLES_URL, {'name': 'X'}).status_code,
                         status.HTTP_403_FORBIDDEN)


class RoleAssignmentTests(TestCase):
    """Test assigning and removing roles to accounts (D15, D18)."""

    def setUp(self):
        self.security_admin = Users.create_security_admin(
            email='seg@example.com', password=PASSWORD,
            nombres='Juan', apellido_paterno='Pérez')
        self.assistant = Users.create_lab_assistant(
            email='ast@example.com', password=PASSWORD,
            nombres='Ana', apellido_paterno='López')
        self.client = client_for(self.security_admin)

    def patch(self, user, data, client=None):
        return (client or self.client).patch(
            f'{MANAGE_URL}?email={user.email}', data, format='json')

    def test_assign_and_remove_roles(self):
        """Test giving a second role and taking all of them away."""
        res = self.patch(self.assistant, {'roles': [LAB_ASSIST, LAB_ADMIN]})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(roleNames(self.assistant), [LAB_ADMIN, LAB_ASSIST])
        self.assertEqual(res.data['roles'], [LAB_ADMIN, LAB_ASSIST])

        res = self.patch(self.assistant, {'roles': []})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(roleNames(self.assistant), [])

        event = SecurityEvent.objects.filter(
            event_type=SecurityEvent.ACCOUNT_UPDATED).first()
        self.assertEqual(event.detail['cambios']['roles'],
                         [[LAB_ADMIN, LAB_ASSIST], []])

    def test_unknown_role_rejected(self):
        """Test assigning a role that does not exist fails."""
        res = self.patch(self.assistant, {'roles': ['NoExiste']})

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(roleNames(self.assistant), [LAB_ASSIST])

    def test_cannot_add_security_role_to_existing_account(self):
        """Test security roles are given only when creating an account
        (D18)."""
        res = self.patch(self.assistant, {'roles': [SEC_ADMIN]})

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(roleNames(self.assistant), [LAB_ASSIST])

    def test_assigning_roles_requires_its_permission(self):
        """Test modificar_usuarios alone cannot change roles."""
        editor_role = Role.objects.create(name='Editor de cuentas')
        editor_role.permissions.set(Permission.objects.filter(
            codename__in=['ver_usuarios', 'modificar_usuarios']))
        editor = Users.create_with_roles(
            'ed@example.com', PASSWORD, [editor_role],
            nombres='Beto', apellido_paterno='Rojas')
        client = client_for(editor)

        res = self.patch(self.assistant, {'nombres': 'Ana María'}, client)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        res = self.patch(self.assistant, {'roles': [LAB_ADMIN]}, client)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(roleNames(self.assistant), [LAB_ASSIST])

    def test_create_account_with_roles(self):
        """Test creating an account with the roles chosen."""
        res = self.client.post(CREATE_URL, {
            'email': 'nuevo@example.com', 'nombres': 'Luis',
            'apellido_paterno': 'Peña', 'roles': [LAB_ADMIN, LAB_ASSIST]},
            format='json')

        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        user = Users.get(email='nuevo@example.com')
        self.assertEqual(roleNames(user), [LAB_ADMIN, LAB_ASSIST])
        self.assertEqual(user.username, 'usr.lpena')

    def test_create_security_account(self):
        """Test a new account with a security role gets the adm. prefix."""
        res = self.client.post(CREATE_URL, {
            'email': 'seg2@example.com', 'nombres': 'Rosa',
            'apellido_paterno': 'Mamani', 'roles': [SEC_ADMIN]},
            format='json')

        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(res.data['username'], 'adm.rmamani')

    def test_create_account_with_mixed_roles_rejected(self):
        """Test nobody gets security and lab roles together (D18)."""
        res = self.client.post(CREATE_URL, {
            'email': 'nuevo@example.com', 'nombres': 'Luis',
            'apellido_paterno': 'Peña', 'roles': [SEC_ADMIN, LAB_ADMIN]},
            format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(Users.filter(email='nuevo@example.com').exists())

    def test_create_account_without_roles(self):
        """Test an account can be created without roles: it only reaches
        its own profile until it gets one."""
        res = self.client.post(CREATE_URL, {
            'email': 'nuevo@example.com', 'nombres': 'Luis',
            'apellido_paterno': 'Peña'}, format='json')

        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(res.data['roles'], [])
        self.assertEqual(res.data['permissions'], [])

    def test_security_account_flag(self):
        """Test the API tells the app which accounts it cannot edit."""
        res = self.client.get(MANAGE_URL, {'email': self.security_admin.email})
        self.assertTrue(res.data['security_account'])
        res = self.client.get(MANAGE_URL, {'email': self.assistant.email})
        self.assertFalse(res.data['security_account'])

    def test_filter_users_by_role(self):
        """Test the user list filters by role name."""
        res = self.client.get(reverse('user:list'), {'role': LAB_ASSIST})

        self.assertEqual([u['username'] for u in res.data],
                         [self.assistant.username])
