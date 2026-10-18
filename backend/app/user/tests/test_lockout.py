"""
Tests for locking accounts after failed logins (D23)
"""
from io import StringIO
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.core.cache import cache
from django.core.management import call_command
from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from core.models import SecurityEvent, logIn
from core.passwords import create_password_link

TOKEN_URL = reverse('user:token')
USE_URL = reverse('user:password-link')
MANAGE_URL = reverse('user:manage')
PASSWORD = 'Testpass123#Testpass123#'
WRONG_PASSWORD = 'TestBadd123#Testpass123#'
NEW_PASSWORD = 'Desbloqueo456$Desbloqueo456$'

Users = get_user_model().objects


class LockoutTests(TestCase):
    """Test the account locks on the third failed login in a row."""

    def setUp(self):
        self.security_admin = Users.create_security_admin(
            email='seg@example.com', password=PASSWORD,
            nombres='Seg', apellido_paterno='Admin')
        self.user = Users.create_lab_assistant(
            email='ast@example.com', password=PASSWORD,
            nombres='Ana', apellido_paterno='Quispe')
        self.client = APIClient()

    def login(self, password, username=None):
        # El límite de 3 intentos por minuto (D12) es otra protección: se
        # vacía para probar solo el bloqueo.
        cache.clear()
        return self.client.post(TOKEN_URL, {
            'username': username or self.user.username,
            'password': password})

    def fail(self, times):
        for _ in range(times):
            res = self.login(WRONG_PASSWORD)
            self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_locked_on_third_failure(self):
        """Test two failures do not lock; the third does, and then the
        right password is rejected too."""
        self.fail(2)
        self.user.refresh_from_db()
        self.assertFalse(self.user.is_locked)

        self.fail(1)
        self.user.refresh_from_db()
        self.assertTrue(self.user.is_locked)
        res = self.login(PASSWORD)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_success_restarts_count(self):
        """Test a successful login restarts the count of failures."""
        self.fail(2)
        self.assertEqual(self.login(PASSWORD).status_code,
                         status.HTTP_200_OK)

        self.fail(2)

        self.user.refresh_from_db()
        self.assertFalse(self.user.is_locked)
        self.assertEqual(self.user.failed_login_attempts, 2)

    def test_locked_response_reveals_nothing(self):
        """Test a locked account answers exactly like an unknown User ID,
        so the lock does not reveal which accounts exist (D12)."""
        self.fail(3)

        locked = self.login(PASSWORD)
        unknown = self.login(PASSWORD, username='usr.noexiste')

        self.assertEqual(locked.status_code, unknown.status_code)
        self.assertEqual(locked.data, unknown.data)

    def test_lock_recorded(self):
        """Test the lock is recorded once, and later attempts are marked
        as attempts on a locked account."""
        self.fail(3)
        self.login(PASSWORD)

        locks = SecurityEvent.objects.filter(
            event_type=SecurityEvent.ACCOUNT_LOCKED)
        self.assertEqual(locks.count(), 1)
        self.assertEqual(locks.get().target, self.user)
        self.assertEqual(locks.get().detail, {'intentos': 3})
        last_attempt = SecurityEvent.objects.filter(
            event_type=SecurityEvent.LOGIN_FAILED).first()
        self.assertEqual(last_attempt.detail, {'cuenta_bloqueada': True})

    def test_reset_link_unlocks(self):
        """Test choosing a new password with a reset link unlocks the
        account (D24) and records it."""
        self.fail(3)
        _, token = create_password_link(self.user,
                                        created_by=self.security_admin)

        res = APIClient().post(USE_URL, {'token': token,
                                         'password': NEW_PASSWORD})

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(self.login(NEW_PASSWORD).status_code,
                         status.HTTP_200_OK)
        event = SecurityEvent.objects.get(
            event_type=SecurityEvent.ACCOUNT_UNLOCKED)
        self.assertEqual(event.target, self.user)

    def test_changepassword_unlocks_security_admin(self):
        """Test a locked security admin, who gets no links (D27), is
        unlocked with changepassword on the server."""
        for _ in range(3):
            self.login(WRONG_PASSWORD, username=self.security_admin.username)
        self.security_admin.refresh_from_db()
        self.assertTrue(self.security_admin.is_locked)

        with patch('django.contrib.auth.management.commands.'
                   'changepassword.getpass.getpass',
                   return_value=NEW_PASSWORD):
            call_command('changepassword', self.security_admin.username,
                         stdout=StringIO())

        res = self.login(NEW_PASSWORD, username=self.security_admin.username)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_admin_sees_lock(self):
        """Test the security admin sees that an account is locked."""
        self.fail(3)
        client = APIClient()
        client.force_authenticate(user=self.security_admin)
        logIn(self.security_admin)

        res = client.get(MANAGE_URL, {'email': self.user.email})

        self.assertTrue(res.data['is_locked'])
