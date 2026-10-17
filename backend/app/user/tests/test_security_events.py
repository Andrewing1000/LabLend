"""
Tests for the security event log (D28)
"""
from io import StringIO

from django.contrib.auth import get_user_model
from django.core.cache import cache
from django.core.exceptions import PermissionDenied
from django.core.management import call_command
from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from core.models import LAB_ADMIN, LAB_ASSIST, SecurityEvent, logIn

PASSWORD = 'Testpass123#Testpass123#'
NEW_PASSWORD = 'Otrapass456$Otrapass456$'
TOKEN_URL = reverse('user:token')
LOGOUT_URL = reverse('user:logout')
ME_URL = reverse('user:me')
CREATE_URL = reverse('user:create')
MANAGE_URL = reverse('user:manage')
LIST_URL = reverse('user:list')
EVENTS_URL = reverse('user:events')

Users = get_user_model().objects


def client_for(user):
    client = APIClient()
    client.force_authenticate(user=user)
    logIn(user)
    return client


def last_event(event_type):
    return SecurityEvent.objects.filter(event_type=event_type).first()


class EventRecordingTests(TestCase):
    """Test each security-relevant action leaves one event."""

    def setUp(self):
        cache.clear()
        self.security_admin = Users.create_security_admin(
            email='seg@example.com', password=PASSWORD,
            nombres='Juan', apellido_paterno='Pérez')
        self.assistant = Users.create_lab_assistant(
            email='ast@example.com', password=PASSWORD,
            nombres='Ana', apellido_paterno='López')

    def test_login_recorded(self):
        """Test a successful login records who and from which IP."""
        APIClient().post(TOKEN_URL, {'username': 'usr.alopez',
                                     'password': PASSWORD})

        event = last_event(SecurityEvent.LOGIN)
        self.assertEqual(event.actor, self.assistant)
        self.assertEqual(event.actor_username, 'usr.alopez')
        self.assertEqual(event.ip, '127.0.0.1')

    def test_failed_login_existing_account(self):
        """Test a wrong password records the affected account."""
        APIClient().post(TOKEN_URL, {'username': 'usr.alopez',
                                     'password': 'Mala#Contrasena123'})

        event = last_event(SecurityEvent.LOGIN_FAILED)
        self.assertEqual(event.target, self.assistant)
        self.assertEqual(event.actor, None)

    def test_failed_login_never_stores_password(self):
        """Test the typed password is never stored, and text typed in the
        user field is kept only if it looks like a User ID."""
        client = APIClient()
        client.post(TOKEN_URL, {'username': 'usr.nadie',
                                'password': 'Secreta#Contrasena1'})
        client.post(TOKEN_URL, {'username': 'Mi#Contrasena2026',
                                'password': 'Secreta#Contrasena1'})

        events = list(SecurityEvent.objects.filter(
            event_type=SecurityEvent.LOGIN_FAILED).order_by('id'))
        self.assertEqual(events[0].detail, {'codigo_ingresado': 'usr.nadie'})
        self.assertEqual(events[1].detail, {'codigo_ingresado': ''})
        for event in SecurityEvent.objects.all():
            text = (str(event.detail) + event.actor_username
                    + event.target_username).lower()
            self.assertNotIn('secreta#contrasena1', text)
            self.assertNotIn('mi#contrasena2026', text)

    def test_throttled_login_recorded(self):
        """Test logins rejected by the attempt limit are recorded."""
        client = APIClient()
        for _ in range(4):
            client.post(TOKEN_URL, {'username': 'usr.alopez',
                                    'password': 'Mala#Contrasena123'})

        event = last_event(SecurityEvent.LOGIN_THROTTLED)
        self.assertIsNotNone(event)
        self.assertEqual(event.target, self.assistant)

    def test_logout_recorded_and_session_closed(self):
        """Test logout is recorded and the session log gets its end time."""
        client = APIClient()
        client.post(TOKEN_URL, {'username': 'usr.alopez',
                                'password': PASSWORD})
        client.post(LOGOUT_URL)

        self.assertEqual(last_event(SecurityEvent.LOGOUT).actor,
                         self.assistant)
        session = self.assistant.session_set.get()
        self.assertIsNotNone(session.logout_time)

    def test_account_creation_recorded(self):
        """Test creating an account records who created it and the role."""
        client_for(self.security_admin).post(CREATE_URL, {
            'email': 'nuevo@example.com', 'password': PASSWORD,
            'nombres': 'Luis', 'apellido_paterno': 'Peña'})

        event = last_event(SecurityEvent.ACCOUNT_CREATED)
        self.assertEqual(event.actor, self.security_admin)
        self.assertEqual(event.target_username, 'usr.lpena')
        self.assertEqual(event.detail, {'rol': LAB_ASSIST})

    def test_initial_admin_creation_recorded(self):
        """Test create_initial_admin leaves an event without an actor."""
        Users.all().delete()
        call_command('create_initial_admin', email='a@lablend.test',
                     nombres='Rosa', apellido_paterno='Mamani',
                     stdout=StringIO())

        event = last_event(SecurityEvent.ACCOUNT_CREATED)
        self.assertIsNone(event.actor)
        self.assertEqual(event.target_username, 'adm.rmamani')
        self.assertEqual(event.detail['origen'], 'create_initial_admin')

    def test_account_update_recorded(self):
        """Test admin changes record what changed, but not the password."""
        client_for(self.security_admin).patch(
            f'{MANAGE_URL}?email={self.assistant.email}',
            {'is_active': False, 'role_field': LAB_ADMIN,
             'password': NEW_PASSWORD})

        event = last_event(SecurityEvent.ACCOUNT_UPDATED)
        self.assertEqual(event.actor, self.security_admin)
        self.assertEqual(event.target, self.assistant)
        self.assertEqual(event.detail['cambios'], {
            'is_active': [True, False],
            'rol': [LAB_ASSIST, LAB_ADMIN],
        })
        self.assertTrue(event.detail['contrasena_cambiada'])
        self.assertNotIn(NEW_PASSWORD, str(event.detail))

    def test_own_profile_and_password_recorded(self):
        """Test changes through /user/me/ are recorded separately."""
        client_for(self.assistant).patch(
            ME_URL, {'nombres': 'Ana María', 'password': NEW_PASSWORD})

        profile = last_event(SecurityEvent.PROFILE_UPDATED)
        self.assertEqual(profile.detail['cambios'],
                         {'nombres': ['Ana', 'Ana María']})
        password = last_event(SecurityEvent.OWN_PASSWORD_CHANGED)
        self.assertEqual(password.actor, self.assistant)
        self.assertEqual(password.detail, {})

    def test_denied_action_recorded(self):
        """Test a 403 for a logged-in user is recorded with the path."""
        client_for(self.assistant).get(LIST_URL)

        event = last_event(SecurityEvent.ACCESS_DENIED)
        self.assertEqual(event.actor, self.assistant)
        self.assertEqual(event.detail['ruta'], LIST_URL)
        self.assertEqual(event.detail['metodo'], 'GET')


class EventLogIntegrityTests(TestCase):
    """Test events cannot be changed or deleted."""

    def setUp(self):
        self.event = SecurityEvent.objects.create(
            event_type=SecurityEvent.LOGIN, actor_username='usr.alopez')

    def test_event_cannot_be_modified(self):
        self.event.actor_username = 'usr.otro'
        with self.assertRaises(PermissionDenied):
            self.event.save()
        with self.assertRaises(PermissionDenied):
            SecurityEvent.objects.update(actor_username='usr.otro')

    def test_event_cannot_be_deleted(self):
        with self.assertRaises(PermissionDenied):
            self.event.delete()
        with self.assertRaises(PermissionDenied):
            SecurityEvent.objects.all().delete()
        self.assertEqual(SecurityEvent.objects.count(), 1)


class EventLogApiTests(TestCase):
    """Test the event log endpoint."""

    def setUp(self):
        self.security_admin = Users.create_security_admin(
            email='seg@example.com', password=PASSWORD,
            nombres='Juan', apellido_paterno='Pérez')
        self.lab_admin = Users.create_lab_admin(
            email='lab@example.com', password=PASSWORD,
            nombres='María', apellido_paterno='Quispe')
        SecurityEvent.objects.create(event_type=SecurityEvent.LOGIN,
                                     actor_username='usr.mquispe')
        SecurityEvent.objects.create(event_type=SecurityEvent.LOGIN_FAILED,
                                     target_username='adm.jperez')

    def test_security_admin_reads_log(self):
        """Test the security admin gets the events, newest first."""
        res = client_for(self.security_admin).get(EVENTS_URL)

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        types = [e['event_type'] for e in res.data['results']]
        self.assertEqual(types[:2], [SecurityEvent.LOGIN_FAILED,
                                     SecurityEvent.LOGIN])
        self.assertEqual(res.data['results'][0]['event_label'],
                         'Inicio de sesión fallido')

    def test_filters(self):
        """Test filtering by user and by event type."""
        client = client_for(self.security_admin)

        res = client.get(EVENTS_URL, {'usuario': 'usr.mquispe'})
        self.assertEqual([e['actor_username'] for e in res.data['results']],
                         ['usr.mquispe'])
        res = client.get(EVENTS_URL, {'tipo': SecurityEvent.LOGIN_FAILED})
        self.assertEqual(len(res.data['results']), 1)

    def test_other_roles_cannot_read_log(self):
        """Test only the security admin reads the log."""
        res = client_for(self.lab_admin).get(EVENTS_URL)

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_log_is_read_only(self):
        """Test the endpoint does not accept writes."""
        client = client_for(self.security_admin)

        for method in [client.post, client.put, client.patch, client.delete]:
            with self.subTest(method=method.__name__):
                res = method(EVENTS_URL, {})
                self.assertEqual(res.status_code,
                                 status.HTTP_405_METHOD_NOT_ALLOWED)
