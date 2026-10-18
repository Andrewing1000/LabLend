"""
Tests for the user API
"""
from django.core.cache import cache
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.urls import reverse

from rest_framework.test import APIClient
from rest_framework import status
from core.models import User

from core.models import logIn

from unittest.mock import patch

from core.models import LAB_ADMIN, LAB_ASSIST

CREATE_USER_URL = reverse("user:create")
CREATE_ADMIN_URL = reverse("user:create/admin")
TOKEN_URL = reverse("user:token")
ME_URL = reverse("user:me")


def create_user(**params):
    """Create and return a new user."""
    return get_user_model().objects.create_user(**params)

def create_lab_admin(**params):
    """Create and return a new user."""
    return get_user_model().objects.create_lab_admin(**params)

def create_lab_assistant(**params):
    """Create and return a new user."""
    return get_user_model().objects.create_lab_assistant(**params)



class PublicAdminAPITests(TestCase):
    """Test the public features of the user API."""

    def setUp(self):
        # El límite de intentos de login vive en la caché, no en la base de
        # datos: se limpia para que cada prueba empiece sin intentos.
        cache.clear()
        self.user = get_user_model().objects.create_security_admin(
            email = 'admin@example.com',
            password = 'Testpass123#Testpass123#',
            nombres = 'Admin',
            apellido_paterno = 'Prueba',
        )

        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
        logIn(self.user)



    def test_create_user_success(self):
        """Test creating user is succesful"""
        payload = {
            'email' : 'test@example.com',
            'nombres' : 'Juan Carlos',
            'apellido_paterno' : 'Pérez',
            'apellido_materno' : 'Gutiérrez',
        }

        res = self.client.post(CREATE_USER_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

        user = get_user_model().objects.get(email = payload['email'])

        # La cuenta nace sin contraseña, esperando su activación (D26).
        self.assertFalse(user.has_usable_password())
        self.assertTrue(res.data['activation_pending'])
        self.assertNotIn('password', res.data)
        self.assertEqual(res.data['username'], 'usr.jperez')
        self.assertEqual(res.data['name'], 'Juan Carlos Pérez Gutiérrez')

    def test_created_admin_gets_usr_prefix(self):
        """Test lab admins created from the app use the usr. prefix."""
        payload = {
            'email' : 'maria@example.com',
            'nombres' : 'María',
            'apellido_paterno' : 'Quispe',
        }

        res = self.client.post(CREATE_ADMIN_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(res.data['username'], 'usr.mquispe')
        self.assertEqual(res.data['role_field'], LAB_ADMIN)

    def test_username_is_read_only(self):
        """Test the User ID cannot be chosen by the client."""
        payload = {
            'email' : 'test@example.com',
            'nombres' : 'Ana',
            'apellido_paterno' : 'López',
            'username' : 'adm.root',
        }

        res = self.client.post(CREATE_USER_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(res.data['username'], 'usr.alopez')

    def test_name_without_letters_error(self):
        """Test the User ID needs letters in nombres and apellido paterno."""
        payload = {
            'email' : 'test@example.com',
            'nombres' : 'Ana',
            'apellido_paterno' : '123',
        }

        res = self.client.post(CREATE_USER_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('apellido_paterno', res.data)

    def test_user_with_email_exists_error(self):
        """Test error returned if user with email exists"""
        payload = {
            'email' : 'test@example.com',
            'password' : 'Testpass123#Testpass123#',
            'nombres' : 'Test',
            'apellido_paterno' : 'Name',
        }

        create_user(**payload)
        del payload['password']
        res = self.client.post(CREATE_USER_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


    def test_password_too_short_error(self):
        """Test an error is returned if password less then 5 chars."""
        payload  = {
            'email' : 'test@example.com',
            'password' : 'pw',
            'nombres' : 'Test',
            'apellido_paterno' : 'Name',
        }
        res = self.client.post(CREATE_USER_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        user_exists = get_user_model().objects.filter(
            email=payload['email']
        ).exists()
        self.assertFalse(user_exists)

    def test_login_for_user(self):
        """Test valid credentials start a session and return the user."""
        user = create_lab_admin(
            nombres = 'Test',
            apellido_paterno = 'Name',
            email = 'test@example.com',
            password = 'Testpass123#Testpass123#',
        )

        payload = {
            'username' : user.username,
            'password' : 'Testpass123#Testpass123#',
        }
        res = self.client.post(TOKEN_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['username'], user.username)
        self.assertNotIn('password', res.data)
        self.assertIn('sessionid', res.cookies)

    def test_login_user_id_case_insensitive(self):
        """Test the User ID is accepted regardless of letter case."""
        user = create_lab_assistant(
            nombres = 'Test',
            apellido_paterno = 'Name',
            email = 'test@example.com',
            password = 'Testpass123#Testpass123#',
        )

        payload = {
            'username' : user.username.upper(),
            'password' : 'Testpass123#Testpass123#',
        }
        res = self.client.post(TOKEN_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_login_with_email_rejected(self):
        """Test the email is no longer a login credential."""
        create_lab_admin(
            nombres = 'Test',
            apellido_paterno = 'Name',
            email = 'test@example.com',
            password = 'Testpass123#Testpass123#',
        )

        payload = {
            'email' : 'test@example.com',
            'password' : 'Testpass123#Testpass123#',
        }
        res = self.client.post(TOKEN_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertNotIn('sessionid', res.cookies)

    def test_create_token_bad_credentials(self):
        """Test returns error if credentials invalid."""
        user = create_lab_admin(email='test@example.com',
                                password ='Testpass123#Testpass123#',
                                nombres='Test', apellido_paterno='Name')

        payload = {
            'username' : user.username,
            'password' : 'TestBadd123#Testpass123#',
        }
        res = self.client.post(TOKEN_URL, payload)

        self.assertNotIn('username', res.data)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_login_errors_are_identical(self):
        """Test unknown User IDs, wrong passwords and inactive accounts
        get the same response, so it does not reveal who is registered."""
        user = create_lab_assistant(
            email='test@example.com', password='Testpass123#Testpass123#',
            nombres='Test', apellido_paterno='Name')
        inactive = create_lab_assistant(
            email='off@example.com', password='Testpass123#Testpass123#',
            nombres='Inactive', apellido_paterno='User', is_active=False)

        attempts = {
            'unknown': {'username': 'usr.nadie',
                        'password': 'Testpass123#Testpass123#'},
            'wrong_password': {'username': user.username,
                               'password': 'TestBadd123#Testpass123#'},
            'inactive': {'username': inactive.username,
                         'password': 'Testpass123#Testpass123#'},
        }
        for case, payload in attempts.items():
            with self.subTest(case=case):
                res = self.client.post(TOKEN_URL, payload)

                self.assertEqual(res.status_code,
                                 status.HTTP_401_UNAUTHORIZED)
                self.assertEqual(res.data, {
                    'message': 'Código de usuario o contraseña incorrectos'})

    def test_unknown_user_id_throttled(self):
        """Test unknown User IDs are rate limited like existing ones."""
        payload = {'username': 'usr.nadie', 'password': 'BadPass'}

        for _ in range(3):
            self.client.post(TOKEN_URL, payload)
        res = self.client.post(TOKEN_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_429_TOO_MANY_REQUESTS)

    def test_create_token_blank_password(self):
        """Test posting a blank password returns an error."""
        payload = {
            'username' : 'usr.tname',
            'password' : '',
        }
        res = self.client.post(TOKEN_URL, payload)

        self.assertNotIn('token', res.data)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_retrieve_user_unauthorized(self):
        """Test authentication is required for users."""
        self.client.logout()
        res = self.client.get(ME_URL)

        # Con autenticación por sesión, DRF responde 403 sin credenciales.
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_reject_random_payload(self):
        """Test posting unformated body in a post return an error"""
        payload = {
            'email1' : 'test@example.com',
            'password' : 'Testpass123#Testpass123#',
            'nombres' : 'Test',
            'apellido_paterno' : 'Name',
            'gender' : 'Why do you care?'}
        res = self.client.post(CREATE_USER_URL, payload)


        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


    def test_token_request_throtling(self):
        """Test that too many failed authentication requests block the API for a period."""
        user = create_lab_admin(
            nombres = 'Test',
            apellido_paterno = 'Name',
            email = "test@example.com",
            password = 'Testpass123#Testpass123#',
        )

        payload = {
            'username' : user.username,
            'password' : "BadPass",
        }

        self.client.post(TOKEN_URL, payload)
        self.client.post(TOKEN_URL, payload)
        self.client.post(TOKEN_URL, payload)
        self.client.post(TOKEN_URL, payload)

        payload = {
            'username' : user.username,
            'password' : 'Testpass123#Testpass123#',
        }
        res = self.client.post(TOKEN_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_429_TOO_MANY_REQUESTS)



class PrivateUserAPITests(TestCase):
    """Test API requests that requiere authentication."""
    def setUp(self):
        self.user = create_lab_admin(
            email = 'test@example.com',
            password = 'Testpass123#Testpass123#',
            nombres = 'Test',
            apellido_paterno = 'Name',
        )

        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
        logIn(self.user)

    def test_retrieve_profile_success(self):
        """Test retrieving profine for logged in user."""
        res = self.client.get(ME_URL)

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data, {
                'username' : 'usr.tname',
                'email' : self.user.email,
                'nombres' : 'Test',
                'apellido_paterno' : 'Name',
                'apellido_materno' : '',
                'name' : 'Test Name',
                'is_active' : True,
                'role_field' : LAB_ADMIN,
                'activation_pending' : False,
                'is_locked' : False,
            }
        )

    def test_post_me_not_alowed(self):
        """Test POST is not allowed for the me endpoint."""
        res = self.client.post(ME_URL, {})

        self.assertEqual(res.status_code, status.HTTP_405_METHOD_NOT_ALLOWED)

    def test_update_user_profile(self):
        """Test updating the user profile for the authenticated user."""
        payload = {'nombres': 'Updated', 'password':  'Otrapass456$Otrapass456$',
                   'current_password': 'Testpass123#Testpass123#'}

        res = self.client.patch(ME_URL, payload)

        self.user.refresh_from_db()
        self.assertEqual(self.user.nombres, payload['nombres'])
        self.assertTrue(self.user.check_password(payload['password']))
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_name_change_keeps_user_id(self):
        """Test the User ID never changes after the account is created."""
        res = self.client.patch(ME_URL, {'apellido_paterno': 'Otro'})

        self.user.refresh_from_db()
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(self.user.username, 'usr.tname')
