"""
Tests for the password history (D22)
"""
from io import StringIO
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.core.management import call_command
from django.core.management.base import CommandError
from django.test import TestCase
from django.urls import reverse
from django_password_validators.password_history.models import (
    PasswordHistory,
)
from rest_framework import status
from rest_framework.test import APIClient

from core.models import logIn

ME_URL = reverse('user:me')
MANAGE_URL = reverse('user:manage')
PASSWORD = 'Testpass123#Testpass123#'
REUSED_MESSAGE = ('La contraseña no puede ser igual a la actual ni a las '
                  '4 anteriores.')


def new_password(number):
    """Return a password that satisfies the policy, distinct per number."""
    return f'Laboratorio{number}#Prueba'


class PasswordHistoryTests(TestCase):
    """Test the current password and the 4 before it cannot be reused."""

    def setUp(self):
        self.admin = get_user_model().objects.create_security_admin(
            email='admin@example.com', password=PASSWORD,
            nombres='Admin', apellido_paterno='Prueba',
        )
        self.assistant = get_user_model().objects.create_lab_assistant(
            email='assistant@example.com', password=PASSWORD,
            nombres='Assistant', apellido_paterno='Prueba',
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.admin)
        logIn(self.admin)

    def change_own_password(self, password):
        return self.client.patch(ME_URL, {'password': password})

    def test_current_password_rejected(self):
        """Test the current password cannot be set again."""
        res = self.change_own_password(PASSWORD)

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data['password'], [REUSED_MESSAGE])

    def test_previous_passwords_rejected(self):
        """Test each of the 4 passwords before the current one is
        rejected, and the current one stays unchanged."""
        for number in range(1, 5):
            res = self.change_own_password(new_password(number))
            self.assertEqual(res.status_code, status.HTTP_200_OK)

        for reused in [PASSWORD] + [new_password(n) for n in range(1, 4)]:
            with self.subTest(password=reused):
                res = self.change_own_password(reused)

                self.assertEqual(res.status_code,
                                 status.HTTP_400_BAD_REQUEST)
                self.assertEqual(res.data['password'], [REUSED_MESSAGE])
                self.admin.refresh_from_db()
                self.assertTrue(self.admin.check_password(new_password(4)))

    def test_older_password_accepted(self):
        """Test a password older than the last 5 can be used again."""
        for number in range(1, 6):
            res = self.change_own_password(new_password(number))
            self.assertEqual(res.status_code, status.HTTP_200_OK)

        res = self.change_own_password(PASSWORD)

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.admin.refresh_from_db()
        self.assertTrue(self.admin.check_password(PASSWORD))

    def test_managed_change_rejects_reuse(self):
        """Test the history also applies when an admin changes the
        password of another account."""
        url = f'{MANAGE_URL}?email={self.assistant.email}'
        res = self.client.patch(url, {'password': PASSWORD})

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data['password'], [REUSED_MESSAGE])

    def test_changepassword_command_rejects_reuse(self):
        """Test the history also applies to the changepassword command."""
        with patch('django.contrib.auth.management.commands.'
                   'changepassword.getpass.getpass', return_value=PASSWORD):
            with self.assertRaises(CommandError):
                call_command('changepassword', self.admin.username,
                             stdout=StringIO(), stderr=StringIO())

    def test_history_stores_only_hashes(self):
        """Test the history keeps PBKDF2 hashes with fixed iterations,
        never the password, and at most 5 per user."""
        for number in range(1, 8):
            self.change_own_password(new_password(number))

        history = PasswordHistory.objects.filter(
            user_config__user=self.admin)
        self.assertEqual(history.count(), 5)
        for entry in history:
            self.assertTrue(
                entry.password.startswith('pbkdf2_sha256$1000000$'))
            self.assertNotIn('Laboratorio', entry.password)
