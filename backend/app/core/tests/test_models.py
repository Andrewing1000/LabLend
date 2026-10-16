"""
Tests for models
"""

from unittest.mock import patch
from decimal import Decimal

from django.test import TestCase
from django.contrib.auth import get_user_model #Helper function to get (Default)CustomUserMoldel

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

    def test_create_superuser(self):
        """Test creating a superuser."""
        user = get_user_model().objects.create_superuser(
            'test1@example.com',
            PASSWORD,
            **NAMES,
        )

        self.assertTrue(user.is_superuser)
        self.assertTrue(user.is_staff)
        self.assertEqual(user.username, 'adm.tuser')


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
