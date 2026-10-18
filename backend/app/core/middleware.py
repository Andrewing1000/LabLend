from django.contrib.sessions.middleware import SessionMiddleware
from django.http import JsonResponse
from django.urls import Resolver404, resolve
from django.utils import timezone
from core.models import logOut, Session

class CustomSessionExpirationMiddleware(SessionMiddleware):
    def process_request(self, request):
        super().process_request(request)

        # Check if session cookie exists and has expired
        if request.session.session_key:
            session_expires_at = request.session.get_expiry_date()
            if session_expires_at and session_expires_at <= timezone.now():
                # Session has expired, trigger logout for custom session class
                try:
                    custom_session = Session.objects.filter(session_key=request.session.session_key).first()
                    user = custom_session.user
                    logOut(user)  # Example: Trigger logout method in your custom session class
                except():
                    pass  # Session record not found, no action required


PASSWORD_EXPIRED_MESSAGE = ('Su contraseña venció. Cámbiela para continuar: '
                            'ingrese la actual y una nueva.')

# Lo único que acepta el servidor de un usuario con la contraseña vencida
# (D21): ver y cambiar su contraseña en su perfil, y cerrar la sesión.
# También la verificación de estado, que no devuelve datos: la aplicación
# la usa para saber si hay conexión, y sin ella no podría ni iniciar sesión.
PASSWORD_EXPIRED_ALLOWED = {'user:me', 'user:logout', 'user:token',
                            'health_check'}


class PasswordExpiredMiddleware:
    """Reject every request of a user whose password expired (D21),
    except the ones needed to change it or to log out.

    It runs on every request, not in each view, so a modified app cannot
    skip the change by calling another endpoint.
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        user = getattr(request, 'user', None)
        if (user is not None and user.is_authenticated
                and user.password_expired and not self.allowed(request)):
            return JsonResponse(
                {'detail': PASSWORD_EXPIRED_MESSAGE,
                 'code': 'password_expired'},
                status=403)
        return self.get_response(request)

    def allowed(self, request):
        try:
            view_name = resolve(request.path_info).view_name
        except Resolver404:
            return False
        return view_name in PASSWORD_EXPIRED_ALLOWED
