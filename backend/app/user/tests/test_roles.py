"""
Tests for the separation between security admin and lab roles (D18)
"""
from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from core.models import (LAB_ADMIN, LAB_ASSIST, SEC_ADMIN, Role, logIn)

PASSWORD = 'Testpass123#Testpass123#'
LIST_URL = reverse('user:list')
CREATE_URL = reverse('user:create')
CREATE_ADMIN_URL = reverse('user:create/admin')
MANAGE_URL = reverse('user:manage')
LOG_URL = reverse('user:log')
ITEMS_URL = '/item/items/'
LOANS_URL = '/loan/loan/'

Users = get_user_model().objects


def client_for(user):
    """Return an API client logged in as the user."""
    client = APIClient()
    client.force_authenticate(user=user)
    logIn(user)
    return client


class SecurityAdminRoleTests(TestCase):
    """Test the security admin manages accounts and nothing else."""

    def setUp(self):
        self.security_admin = Users.create_security_admin(
            email='seg@example.com', password=PASSWORD,
            nombres='Juan', apellido_paterno='Pérez')
        self.lab_admin = Users.create_lab_admin(
            email='lab@example.com', password=PASSWORD,
            nombres='María', apellido_paterno='Quispe')
        self.assistant = Users.create_lab_assistant(
            email='ast@example.com', password=PASSWORD,
            nombres='Ana', apellido_paterno='López')

    def test_role_created_by_migrations(self):
        """Test migrating creates the security admin role."""
        self.assertTrue(Role.objects.filter(role_name=SEC_ADMIN).exists())

    def test_security_admin_user_id_prefix(self):
        """Test security admins get the adm. prefix."""
        self.assertEqual(self.security_admin.username, 'adm.jperez')
        self.assertEqual(self.security_admin.role.role_name, SEC_ADMIN)

    def test_security_admin_manages_accounts(self):
        """Test the security admin can use every account endpoint."""
        client = client_for(self.security_admin)
        payload = {'email': 'nuevo@example.com', 'password': PASSWORD,
                   'nombres': 'Luis', 'apellido_paterno': 'Peña'}

        self.assertEqual(client.get(LIST_URL).status_code, status.HTTP_200_OK)
        self.assertEqual(client.post(CREATE_URL, payload).status_code,
                         status.HTTP_201_CREATED)
        res = client.get(MANAGE_URL, {'email': self.assistant.email})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        res = client.get(LOG_URL, {'email': self.assistant.email})
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_lab_admin_cannot_manage_accounts(self):
        """Test the lab admin no longer reaches the account endpoints."""
        client = client_for(self.lab_admin)
        payload = {'email': 'nuevo@example.com', 'password': PASSWORD,
                   'nombres': 'Luis', 'apellido_paterno': 'Peña'}

        requests = {
            'list': lambda: client.get(LIST_URL),
            'create': lambda: client.post(CREATE_URL, payload),
            'create_admin': lambda: client.post(CREATE_ADMIN_URL, payload),
            'manage': lambda: client.patch(
                f'{MANAGE_URL}?email={self.assistant.email}',
                {'nombres': 'Otro'}),
            'log': lambda: client.get(LOG_URL,
                                      {'email': self.assistant.email}),
        }
        for name, request in requests.items():
            with self.subTest(endpoint=name):
                self.assertEqual(request().status_code,
                                 status.HTTP_403_FORBIDDEN)
        self.assertFalse(Users.filter(email='nuevo@example.com').exists())

    def test_security_admin_cannot_manage_inventory_or_loans(self):
        """Test the security admin has no access to lab operations."""
        client = client_for(self.security_admin)

        self.assertEqual(client.post(ITEMS_URL, {'name': 'Osciloscopio'})
                         .status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(client.get(LOANS_URL).status_code,
                         status.HTTP_403_FORBIDDEN)

    def test_lab_staff_keep_loans(self):
        """Test lab admins and assistants still reach loans."""
        for user in [self.lab_admin, self.assistant]:
            with self.subTest(role=user.role.role_name):
                res = client_for(user).get(LOANS_URL)
                self.assertEqual(res.status_code, status.HTTP_200_OK)


class RoleSegregationTests(TestCase):
    """Test nobody can hold both the security and the lab admin role."""

    def setUp(self):
        self.security_admin = Users.create_security_admin(
            email='seg@example.com', password=PASSWORD,
            nombres='Juan', apellido_paterno='Pérez')
        self.lab_admin = Users.create_lab_admin(
            email='lab@example.com', password=PASSWORD,
            nombres='María', apellido_paterno='Quispe')
        self.client = client_for(self.security_admin)

    def patch(self, user, data):
        return self.client.patch(f'{MANAGE_URL}?email={user.email}', data)

    def test_cannot_grant_security_admin_role(self):
        """Test a lab admin cannot be turned into a security admin."""
        res = self.patch(self.lab_admin,
                         {'role_field': SEC_ADMIN, 'nombres': 'Otro'})

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.lab_admin.refresh_from_db()
        self.assertEqual(self.lab_admin.role.role_name, LAB_ADMIN)
        self.assertEqual(self.lab_admin.nombres, 'María')

    def test_cannot_remove_security_admin_role(self):
        """Test a security admin cannot be turned into a lab role: the
        account cannot be modified at all from /user/manage/ (D27)."""
        for role in [LAB_ADMIN, LAB_ASSIST]:
            with self.subTest(role=role):
                res = self.patch(self.security_admin, {'role_field': role})

                self.assertEqual(res.status_code,
                                 status.HTTP_403_FORBIDDEN)
                self.security_admin.refresh_from_db()
                self.assertEqual(self.security_admin.role.role_name,
                                 SEC_ADMIN)

    def test_same_role_is_not_a_change(self):
        """Test editing an account while sending its own role works,
        as the app sends the current role on every edit."""
        res = self.patch(self.lab_admin,
                         {'role_field': LAB_ADMIN, 'nombres': 'María José'})

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.lab_admin.refresh_from_db()
        self.assertEqual(self.lab_admin.nombres, 'María José')

    def test_cannot_edit_another_security_admin(self):
        """Test a security admin cannot modify or deactivate another one
        (D27)."""
        other = Users.create_security_admin(
            email='seg2@example.com', password=PASSWORD,
            nombres='Beto', apellido_paterno='Rojas')

        for data in [{'is_active': False}, {'password': 'Otrapass456$Otrapass456$'},
                     {'nombres': 'Otro'}]:
            with self.subTest(data=data):
                res = self.patch(other, data)

                self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        other.refresh_from_db()
        self.assertTrue(other.is_active)
        self.assertEqual(other.nombres, 'Beto')
        self.assertTrue(other.check_password(PASSWORD))

    def test_cannot_edit_own_account_from_manage(self):
        """Test a security admin edits their own data only from /user/me/
        (D27)."""
        res = self.patch(self.security_admin, {'is_active': False})

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.security_admin.refresh_from_db()
        self.assertTrue(self.security_admin.is_active)

    def test_can_view_security_admin_account(self):
        """Test reading a security admin account is still allowed."""
        res = self.client.get(MANAGE_URL, {'email': self.security_admin.email})

        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_lab_roles_can_still_change(self):
        """Test lab admin and assistant roles can still be swapped."""
        res = self.patch(self.lab_admin, {'role_field': LAB_ASSIST})

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.lab_admin.refresh_from_db()
        self.assertEqual(self.lab_admin.role.role_name, LAB_ASSIST)
