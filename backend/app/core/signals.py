from django.core.exceptions import PermissionDenied, ValidationError
from django.db.models.signals import post_migrate, pre_delete
from django.dispatch import receiver
from core.models import Permission, Role
from core.rbac import sync_permissions, sync_security_admin_role


@receiver(post_migrate)
def add_initial_data(sender, **kwargs):
    """Keep the permission catalog and the security admin role in sync
    with core.rbac after every migration (D15, D27)."""
    if sender.name == 'core':
        sync_permissions(Permission)
        sync_security_admin_role(Role, Permission)


@receiver(pre_delete, sender=Role)
def protect_roles(sender, instance, **kwargs):
    """The security admin role can never be deleted (D27), even without
    users, and a role with users is not deleted: removing it would leave
    them without access without anyone deciding it. Also covers bulk
    deletes from the server shell."""
    if instance.protected:
        raise PermissionDenied(
            'El rol de administrador de seguridad no se puede eliminar.')
    if instance.users.exists():
        raise ValidationError(
            'El rol tiene usuarios asignados: quíteselo antes de '
            'eliminarlo.')
