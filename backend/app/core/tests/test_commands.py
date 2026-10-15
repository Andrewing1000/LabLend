"""
Test custom Django management commands
"""

from unittest.mock import patch

from psycopg2 import OperationalError as Psycop2Error

from io import StringIO

from django.contrib.auth import get_user_model
from django.core.management import CommandError, call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase, TestCase

from core.models import LAB_ADMIN


@patch("core.management.commands.wait_for_db.Command.check")
class CommandTests(SimpleTestCase):
    """Tests commands."""
    def test_wait_for_db_ready(self, patched_check):
        """Test waiting for database if database ready"""
        patched_check.return_value = True

        call_command('wait_for_db')

        patched_check.assert_called_once_with(databases=['default'])

    @patch('time.sleep')
    def test_wait_for_db_delay(self, patched_sleep, patched_check):
        """Test waiting for database when getting OperationalError"""
        patched_check.side_effect = [Psycop2Error] * 2 + \
            [OperationalError] * 3 + [True]

        call_command('wait_for_db')
        self.assertEqual(patched_check.call_count, 6)
        patched_check.assert_called_with(databases=['default'])


class CreateInitialAdminTests(TestCase):
    """Tests for the create_initial_admin command."""

    def create_admin(self, email='admin@lablend.test'):
        out = StringIO()
        call_command('create_initial_admin', email=email,
                     name='Admin', stdout=out)
        return out.getvalue().split('Password: ')[1].splitlines()[0]

    def test_migrations_create_no_users(self):
        """Test migrating does not create a default account."""
        self.assertFalse(get_user_model().objects.exists())

    def test_create_initial_admin(self):
        """Test the command creates an admin with the printed password."""
        password = self.create_admin()

        user = get_user_model().objects.get(email='admin@lablend.test')
        self.assertEqual(user.role.role_name, LAB_ADMIN)
        self.assertFalse(user.is_superuser)
        self.assertTrue(user.check_password(password))

    def test_passwords_are_unique(self):
        """Test each run generates a different password."""
        first = self.create_admin('first@lablend.test')
        get_user_model().objects.all().delete()
        second = self.create_admin('second@lablend.test')

        self.assertNotEqual(first, second)

    def test_admin_already_exists_error(self):
        """Test the command refuses to create a second administrator."""
        self.create_admin()

        with self.assertRaises(CommandError):
            self.create_admin('other@lablend.test')
        self.assertEqual(get_user_model().objects.count(), 1)
