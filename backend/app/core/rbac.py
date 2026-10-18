"""
Role-based access control (D15): the catalog of permissions and the
default roles.

Each permission is one function of the system, and every API view
declares the permission it requires (D16). The catalog lives in code
because the functions do: a permission without a view that checks it
would do nothing. Roles, and which permissions each one has, live in the
database and are managed from the app.

This module does not import the models, so migrations can use it.
"""

SECURITY_AREA = 'seguridad'
LAB_AREA = 'laboratorio'
AREAS = [
    (SECURITY_AREA, 'Seguridad'),
    (LAB_AREA, 'Laboratorio'),
]

LAB_ADMIN = 'AdministradorLaboratorio'
LAB_ASSIST = 'AsistenteLaboratorio'
SEC_ADMIN = 'AdministradorSeguridad'

# (codename, descripción, área)
PERMISSIONS = [
    ('ver_usuarios', 'Ver la lista de usuarios y los datos de cada cuenta',
     SECURITY_AREA),
    ('crear_usuarios', 'Crear cuentas de usuario', SECURITY_AREA),
    ('modificar_usuarios', 'Modificar, desactivar y reactivar cuentas',
     SECURITY_AREA),
    ('asignar_roles', 'Asignar y quitar roles a los usuarios',
     SECURITY_AREA),
    ('generar_enlaces',
     'Generar enlaces de activación y de restablecimiento de contraseña',
     SECURITY_AREA),
    ('ver_bitacoras',
     'Consultar la bitácora de sesiones y la bitácora de seguridad',
     SECURITY_AREA),
    ('ver_roles', 'Ver los roles, sus permisos y el catálogo de permisos',
     SECURITY_AREA),
    ('gestionar_roles', 'Crear, modificar y eliminar roles', SECURITY_AREA),
    ('gestionar_inventario',
     'Crear, modificar y eliminar equipos, marcas y categorías', LAB_AREA),
    ('registrar_prestamos',
     'Registrar préstamos, y consultar y cerrar los propios', LAB_AREA),
    ('ver_todos_prestamos',
     'Ver y cerrar los préstamos de todos los usuarios', LAB_AREA),
]

SECURITY_PERMISSIONS = [codename for codename, _, area in PERMISSIONS
                        if area == SECURITY_AREA]

# Roles que se crean al instalar el sistema. Los del laboratorio se pueden
# modificar o eliminar desde la aplicación; el de administrador de
# seguridad está protegido (D27) y siempre tiene todos los permisos de
# seguridad.
DEFAULT_ROLES = {
    SEC_ADMIN: {
        'description': 'Gestiona las cuentas, los roles y las bitácoras. '
                       'No gestiona el inventario ni los préstamos.',
        'permissions': SECURITY_PERMISSIONS,
        'protected': True,
    },
    LAB_ADMIN: {
        'description': 'Gestiona el inventario y ve todos los préstamos.',
        'permissions': ['gestionar_inventario', 'registrar_prestamos',
                        'ver_todos_prestamos'],
        'protected': False,
    },
    LAB_ASSIST: {
        'description': 'Registra préstamos y ve los propios.',
        'permissions': ['registrar_prestamos'],
        'protected': False,
    },
}


def sync_permissions(Permission):
    """Make the permission table match the catalog: add new permissions,
    update descriptions and remove the ones no view checks anymore."""
    for codename, name, area in PERMISSIONS:
        Permission.objects.update_or_create(
            codename=codename, defaults={'name': name, 'area': area})
    Permission.objects.exclude(
        codename__in=[codename for codename, _, _ in PERMISSIONS]).delete()


def create_default_role(Role, Permission, name):
    """Create a default role with its permissions, or return it if it
    already exists."""
    data = DEFAULT_ROLES[name]
    role, created = Role.objects.get_or_create(
        name=name, defaults={'description': data['description'],
                             'protected': data['protected']})
    if created:
        role.permissions.set(
            Permission.objects.filter(codename__in=data['permissions']))
    return role


def sync_security_admin_role(Role, Permission):
    """The security admin role always exists, is protected and has every
    security permission (D27): the system never stays without someone who
    can manage accounts and roles."""
    role = create_default_role(Role, Permission, SEC_ADMIN)
    if not role.protected:
        role.protected = True
        role.save(update_fields=['protected'])
    role.permissions.set(
        Permission.objects.filter(codename__in=SECURITY_PERMISSIONS))
    return role
