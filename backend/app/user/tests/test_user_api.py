"""
Tests for the user API
"""
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
        self.user = create_lab_admin(
            email = 'admin@example.com',
            password = 'Testpass123#Testpass123#',
            name ='Test Name',
        )

        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
        logIn(self.user)



    def test_create_user_success(self):
        """Test creating user is succesful"""
        payload = {
            'email' : 'test@example.com',
            'password' : 'Testpass123#Testpass123#',
            'name' : 'TestName',
        }

        res = self.client.post(CREATE_USER_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

        #create_user(**payload)
        user = get_user_model().objects.get(email = payload['email'])

        self.assertTrue(user.check_password(payload['password']))
        self.assertNotIn('password', res.data)

    def test_user_with_email_exists_error(self):
        """Test error returned if user with email exists"""
        payload = {
            'email' : 'test@example.com',
            'password' : 'Testpass123#Testpass123#',
            'name' : 'Test Name',
        }

        create_user(**payload)
        res = self.client.post(CREATE_USER_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


    def test_password_too_short_error(self):
        """Test an error is returned if password less then 5 chars."""
        payload  = {
            'email' : 'test@example.com',
            'password' : 'pw',
            'name' : 'TestName',
        }
        res = self.client.post(CREATE_USER_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        user_exists = get_user_model().objects.filter(
            email=payload['email']
        ).exists()
        self.assertFalse(user_exists)

    def test_create_token_for_user(self):
        """Test generates tokem for valid credentials."""
        user_details = {
            'name' : 'Test Name',
            'email' : 'test@example.com',
            'password' : 'Testpass123#Testpass123#',
        }
        create_lab_admin(**user_details)

        payload = {
            'email' : user_details['email'],
            'password' : user_details['password'],
        }
        res = self.client.post(TOKEN_URL, payload)

        self.assertIn('token', res.data)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_token_bad_credentials(self):
        """Test returns error if credentials invalid."""
        create_lab_admin(email='test@example.com', password ='Testpass123#Testpass123#',)

        payload = {
            'email' : 'test@example.com',
            'password' : 'TestBadd123#Testpass123#',
        }
        res = self.client.post(TOKEN_URL, payload)

        self.assertNotIn('token', res.data)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_token_blank_password(self):
        """Test posting a blank password returns an error."""
        payload = {
            'email' : 'test@example.com',
            'password' : '',
        }
        res = self.client.post(TOKEN_URL, payload)

        self.assertNotIn('token', res.data)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_retrieve_user_unauthorized(self):
        """Test authentication is required for users."""
        self.client.logout()
        res = self.client.get(ME_URL)

        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_reject_random_payload(self):
        """Test posting unformated body in a post return an error"""
        payload = {
            'email1' : 'test@example.com',
            'password' : 'Testpass123#Testpass123#',
            'name' : 'Test Name',
            'gender' : 'Why do you care?'}
        res = self.client.post(CREATE_USER_URL, payload)


        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


    def test_token_request_throtling(self):
        """Test that too many failed authentication requests block the API for a period."""
        user_info = {
            'name' : 'Test Name',
            'email' : "test@example.com",
            'password' : 'Testpass123#Testpass123#',
        }

        create_lab_admin(**user_info)

        payload = {
            'email' : user_info['email'],
            'password' : "BadPass",
        }

        self.client.post(TOKEN_URL, payload)
        self.client.post(TOKEN_URL, payload)
        self.client.post(TOKEN_URL, payload)
        self.client.post(TOKEN_URL, payload)

        payload = {
            'email' : user_info['email'],
            'password' : user_info['password'],
        }
        res = self.client.post(TOKEN_URL, payload)

        self.assertEqual(res.status_code, status.HTTP_429_TOO_MANY_REQUESTS)



class PrivateUserAPITests(TestCase):
    """Test API requests that requiere authentication."""
    def setUp(self):
        self.user = create_lab_admin(
            email = 'test@example.com',
            password = 'Testpass123#Testpass123#',
            name ='Test Name',
        )

        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
        logIn(self.user)

    def test_retrieve_profile_success(self):
        """Test retrieving profine for logged in user."""
        res = self.client.get(ME_URL)

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data, {
                'name' : self.user.name,
                'email' : self.user.email,
                'is_active' : True,
                'role_field' : LAB_ADMIN,
            }
        )

    def test_post_me_not_alowed(self):
        """Test POST is not allowed for the me endpoint."""
        res = self.client.post(ME_URL, {})

        self.assertEqual(res.status_code, status.HTTP_405_METHOD_NOT_ALLOWED)

    def test_update_user_profile(self):
        """Test updating the user profile for the authenticated user."""
        payload = {'name': 'Updated name', 'password':  'Testpass123#Testpass123#',}

        res = self.client.patch(ME_URL, payload)

        self.user.refresh_from_db()
        self.assertEqual(self.user.name, payload['name'])
        self.assertTrue(self.user.check_password(payload['password']))
        self.assertEqual(res.status_code, status.HTTP_200_OK)