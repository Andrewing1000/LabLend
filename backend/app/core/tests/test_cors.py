"""
Tests for the CORS configuration.
"""
from django.test import TestCase
from django.urls import reverse

HEALTH_CHECK_URL = reverse('health_check')


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
        res = self.preflight('http://localhost:58315')

        self.assertEqual(res['Access-Control-Allow-Origin'],
                         'http://localhost:58315')
        self.assertEqual(res['Access-Control-Allow-Credentials'], 'true')

    def test_other_origin_is_rejected(self):
        """Test an unknown origin gets no CORS headers."""
        res = self.preflight('https://evil.example.com')

        self.assertNotIn('Access-Control-Allow-Origin', res)
        self.assertNotIn('Access-Control-Allow-Credentials', res)
