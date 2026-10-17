"""
Tests for the password policy on password changes
"""
from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from core.models import logIn

ME_URL = reverse('user:me')
MANAGE_URL = reverse('user:manage')
PASSWORD = 'Testpass123#Testpass123#'
WEAK_PASSWORDS = ['a', 'password1234', 'AAAAAAAAAAAAAAAA']


class PasswordChangePolicyTests(TestCase):
    """Test password changes must satisfy the password policy."""

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

    def test_own_weak_password_rejected(self):
        """Test a user cannot change their own password to a weak one."""
        for weak in WEAK_PASSWORDS:
            with self.subTest(password=weak):
                res = self.client.patch(ME_URL, {'password': weak})

                self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertIn('password', res.data)
                self.admin.refresh_from_db()
                self.assertTrue(self.admin.check_password(PASSWORD))

    def test_managed_weak_password_rejected(self):
        """Test an admin cannot set a weak password on another account."""
        url = f'{MANAGE_URL}?email={self.assistant.email}'
        res = self.client.patch(url, {'password': 'a'})

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assistant.refresh_from_db()
        self.assertTrue(self.assistant.check_password(PASSWORD))

    def test_strong_password_accepted(self):
        """Test a password that satisfies the policy is saved."""
        new_password = 'Otrapass456$Otrapass456$'
        res = self.client.patch(ME_URL, {'password': new_password})

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.admin.refresh_from_db()
        self.assertTrue(self.admin.check_password(new_password))


class PasswordRulesTests(TestCase):
    """Test each rule of the password policy on its own."""

    def setUp(self):
        self.user = get_user_model().objects.create_security_admin(
            email='admin@example.com', password=PASSWORD,
            nombres='Admin', apellido_paterno='Prueba',
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
        logIn(self.user)

    def change_password(self, password):
        return self.client.patch(ME_URL, {'password': password})

    def test_each_rule_rejected_alone(self):
        """Test a password breaking only one rule is rejected for it."""
        cases = {
            'laboratorio#2026ucb': 'al menos 1 mayúscula',
            'LABORATORIO#2026UCB': 'al menos 1 minúscula',
            'Laboratorio#UcbLapaz': 'al menos 1 dígito',
            'Laboratorio2026Ucb': 'al menos 1 caracter especial',
            'Laborator#2026Uc': 'al menos 12 letras',
            'Adminexample#com1': 'demasiado similar',
        }
        for password, rule in cases.items():
            with self.subTest(password=password):
                res = self.change_password(password)

                self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertEqual(len(res.data['password']), 1)
                self.assertIn(rule, res.data['password'][0])
                self.user.refresh_from_db()
                self.assertTrue(self.user.check_password(PASSWORD))

    def test_common_and_numeric_rejected(self):
        """Test common and all-numeric passwords report their rule."""
        cases = {
            'Password1234': 'demasiado común',
            '123456789012345678': 'completamente numérica',
        }
        for password, rule in cases.items():
            with self.subTest(password=password):
                res = self.change_password(password)

                self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertTrue(
                    any(rule in error for error in res.data['password']))

    def test_minimum_letters_boundary_accepted(self):
        """Test exactly 12 letters with a digit and a symbol is accepted."""
        res = self.change_password('Laborator#2026Ucb')

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password('Laborator#2026Ucb'))

    def test_unlisted_symbols_not_special(self):
        """Test symbols outside the configured set do not count as special.

        Only ~!@#$%^&*()_+{}":;'[] count (settings.py), so '-' is rejected.
        """
        res = self.change_password('Laboratorio-2026-Ucb')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('al menos 1 caracter especial', res.data['password'][0])

    def test_create_user_weak_password_rejected(self):
        """Test a long but weak password is rejected when creating a user."""
        payload = {
            'email': 'nuevo@example.com',
            'password': 'laboratorio2026ucb',
            'nombres': 'Nuevo',
            'apellido_paterno': 'Prueba',
        }
        res = self.client.post(reverse('user:create'), payload)

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('password', res.data)
        self.assertFalse(get_user_model().objects.filter(
            email=payload['email']).exists())
