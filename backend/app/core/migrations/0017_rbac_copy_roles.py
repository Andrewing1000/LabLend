# Crea el catálogo de permisos y los roles por defecto (D15), y asigna a
# cada usuario el rol nuevo que corresponde a su rol anterior.

from django.db import migrations

from core.rbac import (DEFAULT_ROLES, create_default_role, sync_permissions,
                       sync_security_admin_role)


def copy_roles(apps, schema_editor):
    Permission = apps.get_model('core', 'Permission')
    Role = apps.get_model('core', 'Role')
    User = apps.get_model('core', 'User')

    sync_permissions(Permission)
    for name in DEFAULT_ROLES:
        create_default_role(Role, Permission, name)
    sync_security_admin_role(Role, Permission)

    for user in User.objects.exclude(role=None):
        # El rol anterior usaba su nombre como clave primaria.
        role, _ = Role.objects.get_or_create(name=user.role_id)
        user.roles.add(role)


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0016_rbac_roles'),
    ]

    operations = [
        migrations.RunPython(copy_roles, migrations.RunPython.noop),
    ]
