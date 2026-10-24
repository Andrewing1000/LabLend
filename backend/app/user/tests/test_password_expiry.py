"""
Tests for password expiry after 90 days (D21)
"""
from datetime import timedelta

from django.contrib.auth import get_user_model
from django.core.cache import cache
from django.test import TestCase
from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from core.models import SecurityEvent
from core.passwords import create_password_link

TOKEN_URL = reverse('user:token')
ME_URL = reverse('user:me')
LOGOUT_URL = reverse('user:logout')
LIST_URL = reverse('user:list')
USE_URL = reverse('user:password-link')
PASSWORD = 'Testpass123#Testpass123#'
NEW_PASSWORD = 'Renovada456$Renovada456$'

Users = get_user_model().objects


def age_password(user, days):
    Users.filter(pk=user.pk).update(
        password_changed_at=timezone.now() - timedelta(days=days))
    user.refresh_from_db()


class PasswordAgeTests(TestCase):
    """Test when a password counts as expired."""

    def test_expires_after_90_days(self):
        """Test a password expires after 90 days, not before."""
        user = Users.create_lab_assistant(
            email='ast@example.com', password=PASSWORD,
            nombres='Ana', apellido_paterno='Quispe')
        self.assertFalse(user.password_expired)

        age_password(user, 89)
        self.assertFalse(user.password_expired)
        age_password(user, 91)
        self.assertTrue(user.password_expired)

    def test_expiry_date_is_90_days_after_change(self):
        """Test the expiry date the app shows is the change date plus 90
        days, and that the login returns it."""
        user = Users.create_lab_assistant(
            email='fecha@example.com', password=PASSWORD,
            nombres='Eva', apellido_paterno='Rojas')
        age_password(user, 80)

        self.assertEqual(user.password_expires_at,
                         user.password_changed_at + timedelta(days=90))
        res = APIClient().post(TOKEN_URL, {
            'username': user.username, 'password': PASSWORD})
        self.assertIn('password_expires_at', res.data)
        self.assertIsNotNone(res.data['password_expires_at'])

    def test_pending_activation_has_no_expiry_date(self):
        """Test an account without a password has no expiry date."""
        user = Users.create_lab_assistant(
            email='sinfecha@example.com', nombres='Raúl',
            apellido_paterno='Mena')

        self.assertIsNone(user.password_expires_at)

    def test_pending_activation_not_expired(self):
        """Test an account without a password yet has nothing to expire."""
        user = Users.create_lab_assistant(
            email='nuevo@example.com', nombres='Luis',
            apellido_paterno='Peña')

        self.assertFalse(user.password_expired)


class ExpiredPasswordTests(TestCase):
    """Test a user with an expired password can only change it."""

    def setUp(self):
        cache.clear()
        self.user = Users.create_security_admin(
            email='seg@example.com', password=PASSWORD,
            nombres='Seg', apellido_paterno='Admin')
        age_password(self.user, 91)
        self.client = APIClient()
        self.res = self.client.post(TOKEN_URL, {
            'username': self.user.username, 'password': PASSWORD})

    def change_password(self, password=NEW_PASSWORD):
        return self.client.patch(ME_URL, {
            'password': password, 'current_password': PASSWORD})

    def test_login_reports_expiry(self):
        """Test the login works, says the password expired and is
        recorded."""
        self.assertEqual(self.res.status_code, status.HTTP_200_OK)
        self.assertTrue(self.res.data['password_expired'])
        event = SecurityEvent.objects.get(
            event_type=SecurityEvent.PASSWORD_EXPIRED)
        self.assertEqual(event.target, self.user)

    def test_other_requests_rejected(self):
        """Test the server rejects everything else until the change."""
        res = self.client.get(LIST_URL)

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(res.json()['code'], 'password_expired')

    def test_profile_and_logout_allowed(self):
        """Test the user can still read the profile, the app can still
        check the connection, and the user can log out."""
        self.assertEqual(self.client.get(ME_URL).status_code,
                         status.HTTP_200_OK)
        self.assertEqual(self.client.get(reverse('health_check')).status_code,
                         status.HTTP_200_OK)
        self.assertEqual(self.client.post(LOGOUT_URL).status_code,
                         status.HTTP_202_ACCEPTED)

    def test_profile_accepts_only_password_change(self):
        """Test other profile changes are rejected while expired."""
        res = self.client.patch(ME_URL, {'nombres': 'Otro'})
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

        res = self.client.patch(ME_URL, {
            'nombres': 'Otro', 'password': NEW_PASSWORD,
            'current_password': PASSWORD})
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

        self.user.refresh_from_db()
        self.assertEqual(self.user.nombres, 'Seg')
        self.assertTrue(self.user.check_password(PASSWORD))

    def test_change_unblocks_and_keeps_session(self):
        """Test after changing the password the same session can use the
        rest of the API, and the 90 days start again."""
        res = self.change_password()

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertFalse(res.data['password_expired'])
        self.assertEqual(self.client.get(LIST_URL).status_code,
                         status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertFalse(self.user.password_expired)

    def test_change_requires_current_and_new_password(self):
        """Test the current password is required (D14) and the same
        password cannot be kept (D22)."""
        res = self.client.patch(ME_URL, {'password': NEW_PASSWORD})
        self.assertIn('current_password', res.data)

        res = self.change_password(password=PASSWORD)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('password', res.data)


class LinkResetsAgeTests(TestCase):
    """Test the 90 days also start when the password is chosen with a
    link (D24, D26)."""

    def test_link_restarts_age(self):
        admin = Users.create_security_admin(
            email='seg@example.com', password=PASSWORD,
            nombres='Seg', apellido_paterno='Admin')
        user = Users.create_lab_assistant(
            email='ast@example.com', password=PASSWORD,
            nombres='Ana', apellido_paterno='Quispe')
        age_password(user, 91)
        _, token = create_password_link(user, created_by=admin)

        APIClient().post(USE_URL, {'token': token,
                                   'password': NEW_PASSWORD})

        user.refresh_from_db()
        self.assertFalse(user.password_expired)
