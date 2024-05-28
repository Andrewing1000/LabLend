from django.contrib.sessions.middleware import SessionMiddleware
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
