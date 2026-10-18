"""
Tests for the settings read from environment variables
"""
import os
import subprocess
import sys

from django.conf import settings
from django.test import SimpleTestCase

PRODUCTION_ENV = {
    'DJANGO_ALLOWED_HOSTS': 'lablend.example.edu',
    'CORS_ALLOWED_ORIGINS': 'https://lablend.example.edu',
    'FRONTEND_URL': 'https://lablend.example.edu',
}


def run_manage(*args, **env_overrides):
    """Run manage.py in a new process with the given environment changes.

    A value of None removes the variable from the environment.
    """
    env = os.environ.copy()
    for name in ('DJANGO_DEBUG', 'DJANGO_ALLOWED_HOSTS',
                 'CORS_ALLOWED_ORIGINS', 'FRONTEND_URL'):
        env.pop(name, None)
    for name, value in env_overrides.items():
        if value is None:
            env.pop(name, None)
        else:
            env[name] = value
    return subprocess.run(
        [sys.executable, 'manage.py', *args],
        cwd=settings.BASE_DIR, env=env, capture_output=True, text=True,
    )


class ProductionSettingsTests(SimpleTestCase):
    """Test the server only starts with a safe production configuration."""

    def test_debug_off_by_default(self):
        """Test DEBUG is disabled unless DJANGO_DEBUG enables it."""
        res = run_manage(
            'shell', '-c',
            'from django.conf import settings; print(settings.DEBUG)',
            **PRODUCTION_ENV)

        self.assertEqual(res.returncode, 0, res.stderr)
        self.assertEqual(res.stdout.strip().splitlines()[-1], 'False')

    def test_missing_allowed_hosts_error(self):
        """Test the server refuses to start without ALLOWED_HOSTS."""
        res = run_manage('check', **{**PRODUCTION_ENV,
                                     'DJANGO_ALLOWED_HOSTS': None})

        self.assertNotEqual(res.returncode, 0)
        self.assertIn('Falta DJANGO_ALLOWED_HOSTS', res.stderr)

    def test_missing_cors_origins_error(self):
        """Test the server refuses to start without CORS origins."""
        res = run_manage('check', **{**PRODUCTION_ENV,
                                     'CORS_ALLOWED_ORIGINS': None})

        self.assertNotEqual(res.returncode, 0)
        self.assertIn('Falta CORS_ALLOWED_ORIGINS', res.stderr)

    def test_production_configuration_starts(self):
        """Test the server starts with every production variable defined."""
        res = run_manage('check', **PRODUCTION_ENV)

        self.assertEqual(res.returncode, 0, res.stderr)

    def test_missing_frontend_url_error(self):
        """Test the server refuses to start without FRONTEND_URL, needed
        to build the password reset links."""
        res = run_manage('check', **{**PRODUCTION_ENV,
                                     'FRONTEND_URL': None})

        self.assertNotEqual(res.returncode, 0)
        self.assertIn('Falta FRONTEND_URL', res.stderr)
