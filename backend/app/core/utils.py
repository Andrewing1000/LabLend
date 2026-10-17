from rest_framework import throttling

class LogInThrottle(throttling.UserRateThrottle):

    scope = 'login'

    def get_cache_key(self, request, view):

        if 'username' not in request.data:
            return None
        username = str(request.data['username']).lower()

        # Se limita cualquier código, exista o no: si solo se limitaran los
        # existentes, la respuesta 429 revelaría cuáles están registrados (D12).
        if request.user.is_authenticated and request.user.username == username:
            return None

        return self.cache_format % {
            'scope': self.scope,
            'ident': username
        }


class CurrentPasswordThrottle(throttling.UserRateThrottle):
    """Limit the attempts to confirm the current password in /user/me/.

    Without it, a stolen session could try passwords there without the
    login limit (D14, as D30 for HTTP Basic).
    """

    scope = 'current_password'

    def get_cache_key(self, request, view):
        if 'current_password' not in request.data:
            return None
        return self.cache_format % {
            'scope': self.scope,
            'ident': request.user.pk,
        }
