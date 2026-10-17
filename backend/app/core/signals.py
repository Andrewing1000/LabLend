# In your app's signals.py file
from django.core.exceptions import PermissionDenied
from django.db.models.signals import post_migrate, pre_delete
from django.dispatch import receiver
from core.models import SEC_ADMIN, createRoles
from core.permissions import Role

@receiver(post_migrate)
def add_initial_data(sender, **kwargs):
    if sender.name == 'core':
        createRoles()


@receiver(pre_delete)
def protect_security_admin_role(sender, instance, **kwargs):
    """The security admin role can never be deleted (D27), even without
    users. Connected without sender so it also covers the proxy models."""
    if isinstance(instance, Role) and instance.role_name == SEC_ADMIN:
        raise PermissionDenied(
            'El rol de administrador de seguridad no se puede eliminar.')
