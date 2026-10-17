"""
Replace Django's createsuperuser command: superusers are disabled (D27)
"""
from django.core.management import BaseCommand, CommandError


class Command(BaseCommand):
    """Refuse to create superusers."""

    help = ('Disabled: LabLend has no superusers. Use create_initial_admin '
            'to create the initial security administrator.')

    def add_arguments(self, parser):
        # Mismas opciones que el comando de Django, para que cualquier forma
        # de invocarlo termine en el mensaje de abajo y no en un error de
        # argumentos.
        parser.add_argument('--noinput', '--no-input', action='store_false',
                            dest='interactive')
        parser.add_argument('--username')
        parser.add_argument('--email')
        parser.add_argument('--database')

    def handle(self, *args, **options):
        raise CommandError(
            'Superusers are disabled: every account must have a role. '
            'Use "python manage.py create_initial_admin" to create the '
            'initial security administrator.')
