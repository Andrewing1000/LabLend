"""
Tests for creating accounts with an activation link (D26)
"""
from datetime import timedelta

from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.cache import cache
from django.test import TestCase
from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from core.models import PasswordLink, SecurityEvent, logIn

CREATE_URL = reverse('user:create')
CREATE_ADMIN_URL = reverse('user:create/admin')
LINK_URL = reverse('user:reset-link')
CHECK_URL = reverse('user:password-link-check')
USE_URL = reverse('user:password-link')
TOKEN_URL = reverse('user:token')
PASSWORD = 'Testpass123#Testpass123#'
NEW_PASSWORD = 'Activada456$Activada456$'

Users = get_user_model().objects


def token_of(url):
    return url.split('enlace=')[1]


class ActivationLinkTests(TestCase):
    """Test new accounts get an activation link instead of a password."""

    def setUp(self):
        cache.clear()
        self.security_admin = Users.create_security_admin(
            email='seg@example.com', password=PASSWORD,
            nombres='Seg', apellido_paterno='Admin')
        self.client = APIClient()
        self.client.force_authenticate(user=self.security_admin)
        logIn(self.security_admin)

    def create_account(self, url=CREATE_URL):
        # JSON, como la aplicación: en un formulario, DRF toma la casilla
        # is_active ausente como False y la cuenta nacería desactivada.
        return self.client.post(url, {
            'email': 'nuevo@example.com', 'nombres': 'Luis',
            'apellido_paterno': 'Peña'}, format='json')

    def test_created_account_has_no_password(self):
        """Test a new account waits for activation, without a password."""
        res = self.create_account()

        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        user = Users.get(email='nuevo@example.com')
        self.assertFalse(user.has_usable_password())
        self.assertTrue(user.activation_pending)
        self.assertIsNone(user.password_changed_at)

    def test_activation_link_returned_once(self):
        """Test the creation response carries the activation link, which
        is not cached and is stored only as a hash."""
        for url in (CREATE_URL, CREATE_ADMIN_URL):
            with self.subTest(url=url):
                Users.filter(email='nuevo@example.com').delete()
                res = self.create_account(url)

                link_data = res.data['activation_link']
                self.assertEqual(link_data['purpose'],
                                 PasswordLink.ACTIVATION)
                self.assertTrue(link_data['url'].startswith(
                    f'{settings.FRONTEND_URL}/?enlace='))
                self.assertEqual(res['Cache-Control'], 'no-store')
                link = PasswordLink.objects.get(
                    user__email='nuevo@example.com')
                self.assertNotEqual(link.token_hash,
                                    token_of(link_data['url']))

    def test_creation_events_recorded(self):
        """Test the creation and the activation link are in the log."""
        self.create_account()

        for event_type in (SecurityEvent.ACCOUNT_CREATED,
                           SecurityEvent.ACTIVATION_LINK_CREATED):
            event = SecurityEvent.objects.get(event_type=event_type)
            self.assertEqual(event.actor, self.security_admin)
            self.assertEqual(event.target_username, 'usr.lpena')

    def test_pending_account_cannot_log_in(self):
        """Test an account cannot log in before it is activated."""
        self.create_account()

        res = APIClient().post(TOKEN_URL, {'username': 'usr.lpena',
                                           'password': ''})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        res = APIClient().post(TOKEN_URL, {'username': 'usr.lpena',
                                           'password': PASSWORD})
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_activate_account(self):
        """Test the owner chooses the password with the link, then logs
        in; the activation is recorded."""
        url = self.create_account().data['activation_link']['url']
        client = APIClient()

        res = client.post(CHECK_URL, {'token': token_of(url)})
        self.assertEqual(res.data, {'username': 'usr.lpena',
                                    'purpose': PasswordLink.ACTIVATION})
        res = client.post(USE_URL, {'token': token_of(url),
                                    'password': NEW_PASSWORD})
        self.assertEqual(res.status_code, status.HTTP_200_OK)

        user = Users.get(username='usr.lpena')
        self.assertFalse(user.activation_pending)
        self.assertAlmostEqual(user.password_changed_at, timezone.now(),
                               delta=timedelta(minutes=1))
        res = client.post(TOKEN_URL, {'username': 'usr.lpena',
                                      'password': NEW_PASSWORD})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        event = SecurityEvent.objects.get(
            event_type=SecurityEvent.ACCOUNT_ACTIVATED)
        self.assertEqual(event.actor, user)

    def test_new_activation_link_after_expiry(self):
        """Test the admin generates another activation link when the
        first one expires."""
        first = self.create_account().data['activation_link']['url']
        PasswordLink.objects.update(
            expires_at=timezone.now() - timedelta(seconds=1))
        self.assertEqual(
            APIClient().post(CHECK_URL, {'token': token_of(first)})
            .status_code, status.HTTP_400_BAD_REQUEST)

        res = self.client.post(LINK_URL, {'email': 'nuevo@example.com'})

        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(res.data['purpose'], PasswordLink.ACTIVATION)
        res = APIClient().post(CHECK_URL,
                               {'token': token_of(res.data['url'])})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        event = SecurityEvent.objects.filter(
            event_type=SecurityEvent.ACTIVATION_LINK_CREATED)
        self.assertEqual(event.count(), 2)

    def test_activated_account_gets_reset_link(self):
        """Test an account that chose its password gets a reset link."""
        user = Users.create_lab_assistant(
            email='ast@example.com', password=PASSWORD,
            nombres='Ana', apellido_paterno='Quispe')

        res = self.client.post(LINK_URL, {'email': user.email})

        self.assertEqual(res.data['purpose'], PasswordLink.RESET)
