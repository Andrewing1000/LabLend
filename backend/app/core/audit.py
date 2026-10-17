"""
Security event log (D28): one helper to record every event the same way.
"""
import re

from core.models import SecurityEvent

# Solo se guarda el texto de un inicio de sesión fallido si tiene la forma
# de un código de usuario: así no queda registrada una contraseña escrita
# por error en el campo de usuario.
USER_ID_FORMAT = re.compile(r'^(adm|usr)\.[a-z]+[0-9]*$')


def client_ip(request):
    """IP address of the request, or None.

    Uses REMOTE_ADDR only: X-Forwarded-For can be forged by the client.
    Behind a reverse proxy (D8) this must read the proxy's header instead.
    """
    if request is None:
        return None
    return request.META.get('REMOTE_ADDR') or None


def username_of(user):
    return getattr(user, 'username', '') or ''


def record_event(event_type, request=None, actor=None, target=None,
                 **detail):
    """Add one row to the security event log.

    actor defaults to the authenticated user of the request. Never pass
    passwords in detail.
    """
    if actor is None and request is not None \
            and request.user.is_authenticated:
        actor = request.user
    return SecurityEvent.objects.create(
        event_type=event_type,
        actor=actor,
        actor_username=username_of(actor),
        target=target,
        target_username=username_of(target),
        ip=client_ip(request),
        detail=detail,
    )


def safe_attempted_username(value):
    """The typed User ID if it has the User ID format, else ''."""
    value = str(value or '').strip().lower()
    return value if USER_ID_FORMAT.match(value) else ''
