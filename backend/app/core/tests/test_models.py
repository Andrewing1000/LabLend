"""
Tests for models
"""

from unittest.mock import patch
from decimal import Decimal

from django.test import TestCase
from django.contrib.auth import get_user_model #Helper function to get (Default)CustomUserMoldel
from django.core.exceptions import PermissionDenied, ValidationError
from django.core.management import CommandError, call_command
from django.db import transaction
from django.db.models import ProtectedError

from core import models
from item import models as item_models

PASSWORD = 'Testpass123#Testpass123#'
NAMES = {'nombres': 'Test', 'apellido_paterno': 'User'}


class ModelTests(TestCase):
    """Test models."""

    def test_create_user_with_email_successful(self):
        """Test creating a user with an email is successful"""
        email = 'test@example.com'
        user = get_user_model().objects.create_user(
            email = email,
            password = PASSWORD,
            **NAMES,
        )

        self.assertEqual(user.email, email)
        self.assertTrue(user.check_password(PASSWORD))

    def test_new_user_email_normalized(self):
        """Test email is normalized for new users."""
        sample_emails = [
            ['test1@EXAMPLE.com', 'test1@example.com'],
            ['Test2@Example.com', 'Test2@example.com'],
            ['TEST3@Example.COM', 'TEST3@example.com'],
            ['test4@example.COM', 'test4@example.com'],
        ]
        for email, expected in sample_emails:
            user = get_user_model().objects.create_user(email, PASSWORD,
                                                        **NAMES)
            self.assertEqual(user.email, expected)

    def test_new_user_without_emial_raises_error(self):
        """Test that creating a user without an email raises a ValueError."""
        with self.assertRaises(ValueError):
            get_user_model().objects.create_user('', 'test123', **NAMES)


class NoSuperuserTests(TestCase):
    """Test superusers no longer exist (D27)."""

    def test_no_create_superuser(self):
        """Test the manager cannot create superusers."""
        self.assertFalse(
            hasattr(get_user_model().objects, 'create_superuser'))

    def test_superuser_fields_removed(self):
        """Test is_superuser and is_staff are not database fields, and
        is_superuser is always False."""
        field_names = [f.name for f in get_user_model()._meta.get_fields()]
        self.assertNotIn('is_superuser', field_names)
        self.assertNotIn('is_staff', field_names)

        user = get_user_model().objects.create_user(
            'test1@example.com', PASSWORD, **NAMES)
        self.assertFalse(user.is_superuser)

    def test_createsuperuser_command_disabled(self):
        """Test manage.py createsuperuser refuses to run."""
        with self.assertRaises(CommandError):
            call_command('createsuperuser', interactive=False)
        self.assertFalse(get_user_model().objects.exists())


class SecurityAdminProtectionTests(TestCase):
    """Test the security admin role and accounts are protected (D27)."""

    def create_security_admin(self, email, nombres):
        return get_user_model().objects.create_security_admin(
            email, PASSWORD, nombres=nombres, apellido_paterno='Admin')

    def test_last_security_admin_cannot_be_deactivated(self):
        """Test the only active security admin cannot be deactivated."""
        admin = self.create_security_admin('a@example.com', 'Ana')

        admin.is_active = False
        with self.assertRaises(ValidationError):
            admin.save()
        admin.refresh_from_db()
        self.assertTrue(admin.is_active)

    def test_security_admin_deactivated_if_another_active(self):
        """Test a security admin can be deactivated while another one
        stays active."""
        self.create_security_admin('a@example.com', 'Ana')
        second = self.create_security_admin('b@example.com', 'Beto')

        second.is_active = False
        second.save()

        second.refresh_from_db()
        self.assertFalse(second.is_active)

    def test_security_admin_role_cannot_be_deleted(self):
        """Test the role cannot be deleted, even without users."""
        role = models.getSecurityAdminRole()

        # Django borra sin savepoint: cada intento va en su propio atomic
        # para que el rechazo no anule la transacción de la prueba.
        with self.assertRaises(PermissionDenied), transaction.atomic():
            role.delete()
        with self.assertRaises(PermissionDenied), transaction.atomic():
            models.Role.objects.filter(role_name=models.SEC_ADMIN).delete()
        self.assertTrue(models.Role.objects.filter(
            role_name=models.SEC_ADMIN).exists())

    def test_role_with_users_cannot_be_deleted(self):
        """Test deleting a role with users fails instead of deleting
        the users with it."""
        get_user_model().objects.create_lab_admin(
            'lab@example.com', PASSWORD, **NAMES)

        with self.assertRaises(ProtectedError), transaction.atomic():
            models.getAdminRole().delete()
        self.assertTrue(get_user_model().objects.filter(
            email='lab@example.com').exists())


class UserIdTests(TestCase):
    """Test the generated User ID (D11)."""

    def create(self, email, nombres, apellido_paterno, **extra):
        return get_user_model().objects.create_user(
            email, PASSWORD, nombres=nombres,
            apellido_paterno=apellido_paterno, **extra)

    def test_user_id_format(self):
        """Test the User ID is usr. + first initial + paternal surname."""
        cases = [
            ('Juan', 'Pérez', 'usr.jperez'),
            ('Juan Carlos', 'Pérez', 'usr.jperez2'),
            ('María de los Ángeles', 'Quispe', 'usr.mquispe'),
            ('José Luis', 'De la Cruz', 'usr.jdelacruz'),
            ('Luis', 'Peña', 'usr.lpena'),
            ('ángel', "D'Arco", 'usr.adarco'),
        ]
        for i, (nombres, apellido, expected) in enumerate(cases):
            with self.subTest(nombres=nombres, apellido=apellido):
                user = self.create(f'u{i}@example.com', nombres, apellido)
                self.assertEqual(user.username, expected)

    def test_maternal_surname_not_in_user_id(self):
        """Test the maternal surname is stored but not used in the ID."""
        user = self.create('a@example.com', 'Juan Carlos', 'Pérez',
                           apellido_materno='Gutiérrez')

        self.assertEqual(user.username, 'usr.jperez')
        self.assertEqual(user.name, 'Juan Carlos Pérez Gutiérrez')

    def test_duplicate_names_get_number(self):
        """Test repeated names get 2, 3, ... appended."""
        ids = [self.create(f'u{i}@example.com', 'Ana', 'Lara').username
               for i in range(3)]

        self.assertEqual(ids, ['usr.alara', 'usr.alara2', 'usr.alara3'])

    def test_username_argument_ignored(self):
        """Test a chosen username is replaced by the generated one."""
        user = self.create('a@example.com', 'Ana', 'Lara',
                           username='adm.root')

        self.assertEqual(user.username, 'usr.alara')

    def test_name_without_letters_raises_error(self):
        """Test a User ID cannot be built without letters."""
        with self.assertRaises(ValueError):
            self.create('a@example.com', '123', 'Lara')
        with self.assertRaises(ValueError):
            self.create('b@example.com', 'Ana', '')
