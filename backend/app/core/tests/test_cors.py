"""
Tests for the CORS configuration.
"""
from django.test import TestCase, override_settings
from django.urls import reverse

HEALTH_CHECK_URL = reverse('health_check')

WEB_APP_ORIGIN = 'http://localhost:58315'


# La lista de orígenes viene del entorno (CORS_ALLOWED_ORIGINS), que en el
# servidor publicado lleva su dominio. La prueba fija la suya para comprobar
# el mecanismo sin depender de cómo esté configurada la máquina.
@override_settings(CORS_ALLOWED_ORIGINS=[WEB_APP_ORIGIN])
class CorsTests(TestCase):
    """Test only the system's origins can make cross-origin requests."""

    def preflight(self, origin):
        return self.client.options(
            HEALTH_CHECK_URL,
            HTTP_ORIGIN=origin,
            HTTP_ACCESS_CONTROL_REQUEST_METHOD='GET',
        )

    def test_allowed_origin_gets_cors_headers(self):
        """Test the web app origin is allowed with credentials."""
        res = self.preflight(WEB_APP_ORIGIN)

        self.assertEqual(res['Access-Control-Allow-Origin'], WEB_APP_ORIGIN)
        self.assertEqual(res['Access-Control-Allow-Credentials'], 'true')

    def test_other_origin_is_rejected(self):
        """Test an unknown origin gets no CORS headers."""
        res = self.preflight('https://evil.example.com')

        self.assertNotIn('Access-Control-Allow-Origin', res)
        self.assertNotIn('Access-Control-Allow-Credentials', res)
