"""
Tests for the current password and the fixed email in the profile (D14)
"""
from django.contrib.auth import get_user_model
from django.core.cache import cache
from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from core.models import SecurityEvent, logIn

ME_URL = reverse('user:me')
MANAGE_URL = reverse('user:manage')
PASSWORD = 'Testpass123#Testpass123#'
NEW_PASSWORD = 'Otrapass456$Otrapass456$'
WRONG_PASSWORD = 'TestBadd123#Testpass123#'
MISSING_MESSAGE = 'Ingrese su contraseña actual para cambiar la contraseña.'
WRONG_MESSAGE = 'La contraseña actual es incorrecta.'
EMAIL_MESSAGE = 'El correo no se puede cambiar.'


class CurrentPasswordTests(TestCase):
    """Test the own password changes only with the current password,
    and the email never changes."""

    def setUp(self):
        cache.clear()
        self.user = get_user_model().objects.create_lab_assistant(
            email='test@example.com', password=PASSWORD,
            nombres='Test', apellido_paterno='Name',
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
        logIn(self.user)

    def assert_unchanged(self):
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password(PASSWORD))
        self.assertEqual(self.user.email, 'test@example.com')

    def test_password_change_without_current_rejected(self):
        """Test the password does not change without the current one."""
        res = self.client.patch(ME_URL, {'password': NEW_PASSWORD})

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data['current_password'], [MISSING_MESSAGE])
        self.assert_unchanged()

    def test_password_change_wrong_current_rejected(self):
        """Test a wrong current password is rejected and recorded,
        without storing any password."""
        res = self.client.patch(ME_URL, {
            'password': NEW_PASSWORD, 'current_password': WRONG_PASSWORD})

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data['current_password'], [WRONG_MESSAGE])
        self.assert_unchanged()
        event = SecurityEvent.objects.get(
            event_type=SecurityEvent.CURRENT_PASSWORD_FAILED)
        self.assertEqual(event.actor, self.user)
        self.assertEqual(event.target, self.user)
        self.assertEqual(event.detail, {})

    def test_password_change_with_current_accepted(self):
        """Test the password changes with the right current password."""
        res = self.client.patch(ME_URL, {
            'password': NEW_PASSWORD, 'current_password': PASSWORD})

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertNotIn('current_password', res.data)
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password(NEW_PASSWORD))

    def test_current_checked_before_policy(self):
        """Test a wrong current password is reported before the policy,
        so the history does not reveal whether a guess is the current
        password."""
        res = self.client.patch(ME_URL, {
            'password': PASSWORD, 'current_password': WRONG_PASSWORD})

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data, {'current_password': [WRONG_MESSAGE]})

    def test_own_email_cannot_change(self):
        """Test the own email does not change, even with the current
        password."""
        res = self.client.patch(ME_URL, {
            'email': 'otro@example.com', 'current_password': PASSWORD})

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data['email'], [EMAIL_MESSAGE])
        self.assert_unchanged()

    def test_admin_cannot_change_email(self):
        """Test the security admin cannot change another account's email
        either."""
        admin = get_user_model().objects.create_security_admin(
            email='admin@example.com', password=PASSWORD,
            nombres='Admin', apellido_paterno='Prueba',
        )
        client = APIClient()
        client.force_authenticate(user=admin)
        logIn(admin)

        res = client.patch(f'{MANAGE_URL}?email={self.user.email}',
                           {'email': 'otro@example.com'})

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data['email'], [EMAIL_MESSAGE])
        self.assert_unchanged()

    def test_name_change_without_current_accepted(self):
        """Test the name, or the same email, change without the current
        password."""
        res = self.client.patch(ME_URL, {
            'nombres': 'Otro', 'email': 'test@example.com'})

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertEqual(self.user.nombres, 'Otro')

    def test_attempts_limited(self):
        """Test only 3 attempts per minute to confirm the current
        password, so it cannot be guessed there."""
        for _ in range(3):
            res = self.client.patch(ME_URL, {
                'password': NEW_PASSWORD, 'current_password': WRONG_PASSWORD})
            self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

        res = self.client.patch(ME_URL, {
            'password': NEW_PASSWORD, 'current_password': PASSWORD})

        self.assertEqual(res.status_code, status.HTTP_429_TOO_MANY_REQUESTS)
        self.assert_unchanged()
