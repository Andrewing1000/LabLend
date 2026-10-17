"""
Django command to create the initial administrator account
"""
import secrets
import string

from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.core.management import BaseCommand, CommandError

from core.audit import record_event
from core.models import SEC_ADMIN, SecurityEvent

PASSWORD_LENGTH = 24
SPECIAL_CHARACTERS = '~!@#$%^&*()_+{}":;\'[]'
ALPHABET = string.ascii_letters + string.digits + SPECIAL_CHARACTERS


def generate_password():
    """Generate a random password that satisfies the password policy."""
    while True:
        password = ''.join(secrets.choice(ALPHABET)
                           for _ in range(PASSWORD_LENGTH))
        try:
            validate_password(password)
            return password
        except ValidationError:
            continue


class Command(BaseCommand):
    """Create the first security administrator with a generated password."""

    help = ('Create the initial security administrator account, which '
            'creates every other account from the app. The generated '
            'password is shown only once: store it in the password manager.')

    def add_arguments(self, parser):
        parser.add_argument('--email', required=True)
        parser.add_argument('--nombres', required=True)
        parser.add_argument('--apellido-paterno', required=True)
        parser.add_argument('--apellido-materno', default='')

    def handle(self, *args, **options):
        User = get_user_model()
        if User.objects.filter(role__role_name=SEC_ADMIN).exists():
            raise CommandError(
                'A security administrator account already exists.')
        if User.objects.filter(email=options['email']).exists():
            raise CommandError('A user with that email already exists.')

        password = generate_password()
        try:
            user = User.objects.create_security_admin(
                email=options['email'],
                password=password,
                nombres=options['nombres'],
                apellido_paterno=options['apellido_paterno'],
                apellido_materno=options['apellido_materno'],
            )
        except ValueError:
            raise CommandError(
                '--nombres and --apellido-paterno must contain letters.')
        record_event(SecurityEvent.ACCOUNT_CREATED, target=user,
                     rol=SEC_ADMIN, origen='create_initial_admin')

        self.stdout.write(self.style.SUCCESS(
            f'Security administrator {user.username} created.'))
        self.stdout.write(f'User ID: {user.username}')
        self.stdout.write(f'Password: {password}')
        self.stdout.write(self.style.WARNING(
            'Store this password in the password manager now; '
            'it will not be shown again.'))
