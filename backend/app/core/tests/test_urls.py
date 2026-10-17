"""
Tests for the exposed URLs
"""
from django.conf import settings
from django.test import TestCase
from rest_framework import status


class AdminPanelRemovedTests(TestCase):
    """Test the Django admin panel is not available (D9)."""

    def test_admin_url_not_found(self):
        """Test /admin/ and its login page respond 404."""
        for url in ['/admin/', '/admin/login/']:
            with self.subTest(url=url):
                res = self.client.get(url)

                self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)

    def test_admin_app_not_installed(self):
        """Test the admin app is not installed, so nothing can re-enable
        the panel by only adding a URL."""
        self.assertNotIn('django.contrib.admin', settings.INSTALLED_APPS)
