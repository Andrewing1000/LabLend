from rest_framework import throttling
from django.contrib.auth import get_user_model

class LogInThrottle(throttling.UserRateThrottle):

    scope = 'login'

    def get_cache_key(self, request, view):

        email = ''
        if 'email' in request.data:
            email = request.data['email']
        else: return None

        UserModel = get_user_model()
        query = UserModel.objects.filter(email = UserModel.objects.normalize_email(email))

        if query.exists() and (not request.user.is_authenticated or request.user.email != email):
            ident = email
        else:
            return None

        return self.cache_format % {
            'scope': self.scope,
            'ident': ident
        }

