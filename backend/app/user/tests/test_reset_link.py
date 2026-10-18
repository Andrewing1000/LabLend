"""
Tests for the password reset links (D24)
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
from core.passwords import create_reset_link, hash_token

RESET_LINK_URL = reverse('user:reset-link')
CHECK_URL = reverse('user:password-link-check')
USE_URL = reverse('user:password-link')
TOKEN_URL = reverse('user:token')
ME_URL = reverse('user:me')
PASSWORD = 'Testpass123#Testpass123#'
NEW_PASSWORD = 'Otrapass456$Otrapass456$'
INVALID_MESSAGE = ('El enlace no es válido o venció. Pida uno nuevo al '
                   'administrador de seguridad.')

Users = get_user_model().objects


def client_for(user):
    client = APIClient()
    client.force_authenticate(user=user)
    logIn(user)
    return client


class ResetLinkCreationTests(TestCase):
    """Test the security admin generates reset links."""

    def setUp(self):
        cache.clear()
        self.security_admin = Users.create_security_admin(
            email='seg@example.com', password=PASSWORD,
            nombres='Seg', apellido_paterno='Admin')
        self.assistant = Users.create_lab_assistant(
            email='ast@example.com', password=PASSWORD,
            nombres='Ana', apellido_paterno='Quispe')
        self.client = client_for(self.security_admin)

    def create_link(self, user):
        return self.client.post(RESET_LINK_URL, {'email': user.email})

    def test_create_link(self):
        """Test the link is returned once, and only its hash is stored."""
        res = self.create_link(self.assistant)

        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(res.data['username'], self.assistant.username)
        self.assertTrue(res.data['url'].startswith(
            f'{settings.FRONTEND_URL}/?enlace='))
        self.assertEqual(res['Cache-Control'], 'no-store')
        token = res.data['url'].split('enlace=')[1]
        link = PasswordLink.objects.get(user=self.assistant)
        self.assertEqual(link.token_hash, hash_token(token))
        self.assertNotIn(token, link.token_hash)
        self.assertAlmostEqual(link.expires_at,
                               timezone.now() + timedelta(hours=24),
                               delta=timedelta(minutes=1))

    def test_old_password_stops_working(self):
        """Test the current password stops working when the link is
        generated, in case the account was compromised."""
        self.create_link(self.assistant)

        self.assistant.refresh_from_db()
        self.assertFalse(self.assistant.check_password(PASSWORD))
        res = APIClient().post(TOKEN_URL, {
            'username': self.assistant.username, 'password': PASSWORD})
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_open_sessions_closed(self):
        """Test the account's open sessions stop working."""
        session_client = APIClient()
        res = session_client.post(TOKEN_URL, {
            'username': self.assistant.username, 'password': PASSWORD})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(session_client.get(ME_URL).status_code,
                         status.HTTP_200_OK)

        self.create_link(self.assistant)

        self.assertEqual(session_client.get(ME_URL).status_code,
                         status.HTTP_403_FORBIDDEN)

    def test_creation_recorded_without_token(self):
        """Test the security log records the link, never the token."""
        res = self.create_link(self.assistant)

        event = SecurityEvent.objects.get(
            event_type=SecurityEvent.RESET_LINK_CREATED)
        self.assertEqual(event.actor, self.security_admin)
        self.assertEqual(event.target, self.assistant)
        token = res.data['url'].split('enlace=')[1]
        self.assertNotIn(token, str(event.detail))

    def test_new_link_replaces_previous(self):
        """Test generating a link makes the earlier one stop working."""
        first = self.create_link(self.assistant).data['url']
        self.create_link(self.assistant)

        res = APIClient().post(CHECK_URL,
                               {'token': first.split('enlace=')[1]})

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_only_security_admin_creates_links(self):
        """Test lab roles cannot generate links."""
        lab_admin = Users.create_lab_admin(
            email='lab@example.com', password=PASSWORD,
            nombres='Luis', apellido_paterno='Mamani')
        for user in [lab_admin, self.assistant]:
            with self.subTest(role=user.role.role_name):
                res = client_for(user).post(RESET_LINK_URL,
                                            {'email': self.assistant.email})

                self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assistant.refresh_from_db()
        self.assertTrue(self.assistant.check_password(PASSWORD))

    def test_no_link_for_security_admin(self):
        """Test no link is generated for a security admin account (D27),
        the own one included."""
        other = Users.create_security_admin(
            email='seg2@example.com', password=PASSWORD,
            nombres='Beto', apellido_paterno='Rojas')
        for user in [other, self.security_admin]:
            with self.subTest(email=user.email):
                res = self.create_link(user)

                self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
                user.refresh_from_db()
                self.assertTrue(user.check_password(PASSWORD))

    def test_no_link_for_inactive_or_unknown_account(self):
        """Test inactive accounts get 400 and unknown emails 404."""
        self.assistant.is_active = False
        self.assistant.save()

        self.assertEqual(self.create_link(self.assistant).status_code,
                         status.HTTP_400_BAD_REQUEST)
        res = self.client.post(RESET_LINK_URL, {'email': 'no@example.com'})
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)


class PasswordLinkUseTests(TestCase):
    """Test choosing a new password with a reset link."""

    def setUp(self):
        cache.clear()
        self.security_admin = Users.create_security_admin(
            email='seg@example.com', password=PASSWORD,
            nombres='Seg', apellido_paterno='Admin')
        self.user = Users.create_lab_assistant(
            email='ast@example.com', password=PASSWORD,
            nombres='Ana', apellido_paterno='Quispe')
        self.link, self.token = create_reset_link(
            self.user, created_by=self.security_admin)
        self.client = APIClient()

    def use(self, password, token=None):
        return self.client.post(USE_URL, {
            'token': token or self.token, 'password': password})

    def test_check_shows_user_id(self):
        """Test the link shows whose account it is, without logging in."""
        res = self.client.post(CHECK_URL, {'token': self.token})

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data, {'username': self.user.username,
                                    'purpose': PasswordLink.RESET})

    def test_invalid_token_rejected(self):
        """Test an unknown token gets the generic message."""
        for url, data in [(CHECK_URL, {'token': 'x' * 43}),
                          (USE_URL, {'token': 'x' * 43,
                                     'password': NEW_PASSWORD})]:
            with self.subTest(url=url):
                res = self.client.post(url, data)

                self.assertEqual(res.status_code,
                                 status.HTTP_400_BAD_REQUEST)
                self.assertEqual(res.data['detail'], INVALID_MESSAGE)

    def test_new_password_set(self):
        """Test the new password works and the event is recorded."""
        res = self.use(NEW_PASSWORD)

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        res = self.client.post(TOKEN_URL, {
            'username': self.user.username, 'password': NEW_PASSWORD})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        event = SecurityEvent.objects.get(
            event_type=SecurityEvent.PASSWORD_RESET)
        self.assertEqual(event.actor, self.user)
        self.assertEqual(event.target, self.user)

    def test_link_single_use(self):
        """Test the link stops working once used."""
        self.use(NEW_PASSWORD)

        res = self.use('Terceraclave789%Terceraclave')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data['detail'], INVALID_MESSAGE)
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password(NEW_PASSWORD))

    def test_weak_password_keeps_link(self):
        """Test a password that breaks the policy is rejected and the
        link can still be used."""
        res = self.use('laboratorio2026ucb')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('password', res.data)
        self.assertEqual(self.use(NEW_PASSWORD).status_code,
                         status.HTTP_200_OK)

    def test_expired_link_rejected(self):
        """Test a link older than 24 hours does not work."""
        self.link.expires_at = timezone.now() - timedelta(seconds=1)
        self.link.save()

        res = self.use(NEW_PASSWORD)

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data['detail'], INVALID_MESSAGE)

    def test_deactivated_account_link_rejected(self):
        """Test the link stops working if the account is deactivated."""
        self.user.is_active = False
        self.user.save()

        res = self.use(NEW_PASSWORD)

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
