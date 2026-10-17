"""
Tests for the password hashing algorithm
"""
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import PBKDF2PasswordHasher
from django.test import TestCase

PASSWORD = 'Testpass123#Testpass123#'


class PasswordHashingTests(TestCase):
    """Test passwords are stored with Argon2id."""

    def setUp(self):
        self.user = get_user_model().objects.create_lab_assistant(
            email='test@example.com', password=PASSWORD,
            nombres='Test', apellido_paterno='Name',
        )

    def test_new_password_uses_argon2id(self):
        """Test a new password is stored as an Argon2id hash."""
        self.assertTrue(self.user.password.startswith('argon2$argon2id$'))
        self.assertNotIn(PASSWORD, self.user.password)

    def test_other_algorithms_rejected(self):
        """Test a hash from another algorithm is not accepted, even with
        the right password."""
        self.user.password = PBKDF2PasswordHasher().encode(
            PASSWORD, PBKDF2PasswordHasher().salt())
        self.user.save(update_fields=['password'])

        self.assertFalse(self.user.check_password(PASSWORD))
