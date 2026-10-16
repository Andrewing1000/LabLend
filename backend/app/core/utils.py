from rest_framework import throttling
from django.contrib.auth import get_user_model

class LogInThrottle(throttling.UserRateThrottle):

    scope = 'login'

    def get_cache_key(self, request, view):

        username = ''
        if 'username' in request.data:
            username = str(request.data['username']).lower()
        else: return None

        UserModel = get_user_model()
        query = UserModel.objects.filter(username = username)

        if query.exists() and (not request.user.is_authenticated or request.user.username != username):
            ident = username
        else:
            return None

        return self.cache_format % {
            'scope': self.scope,
            'ident': ident
        }

