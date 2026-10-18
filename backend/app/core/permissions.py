"""
The single permission check of the API (D16).

Every request goes through RolePermission (DEFAULT_PERMISSION_CLASSES):
it requires an open session and the permission of the function the view
declares in required_permission. Only the public views (catalog, login,
password links, health check) replace it with AllowAny.
"""
from django.core.exceptions import ImproperlyConfigured
from rest_framework.permissions import SAFE_METHODS, BasePermission

from core.models import isLogged

# Para vistas que solo requieren una sesión abierta, como el perfil propio
# o el cierre de sesión.
AUTHENTICATED = 'autenticado'


def user_permissions(request):
    """Permissions of the request's user, read once per request."""
    if not hasattr(request, '_rbac_permissions'):
        request._rbac_permissions = request.user.get_permissions()
    return request._rbac_permissions


def has_permission(request, codename):
    return codename in user_permissions(request)


def required_permission(request, view):
    """Permission the view requires for this request.

    required_permission is a codename, AUTHENTICATED, or a dict with the
    codename for reading ('read': GET, HEAD, OPTIONS) and for writing
    ('write': any other method).
    """
    required = getattr(view, 'required_permission', None)
    if required is None:
        # Falla de forma segura: una vista sin permiso declarado no se
        # puede usar, en lugar de quedar abierta a cualquier sesión.
        raise ImproperlyConfigured(
            f'{view.__class__.__name__} does not declare required_permission')
    if isinstance(required, dict):
        return required['read' if request.method in SAFE_METHODS
                        else 'write']
    return required


class RolePermission(BasePermission):
    """Allow the request only if one of the user's roles has the
    permission the view requires."""

    message = 'No tiene permiso para realizar esta acción.'

    def has_permission(self, request, view):
        user = request.user
        if not (user and user.is_authenticated and isLogged(user)):
            return False
        required = required_permission(request, view)
        if required == AUTHENTICATED:
            return True
        return has_permission(request, required)
