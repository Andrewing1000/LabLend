"""
Tests for the API authentication methods
"""
import base64

from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from core.models import logIn

ME_URL = reverse('user:me')


class BasicAuthTests(TestCase):
    """Test the API only accepts session authentication."""

    def test_basic_auth_rejected(self):
        """Test credentials in a Basic auth header are not accepted."""
        user = get_user_model().objects.create_lab_admin(
            email='basic@example.com',
            password='Testpass123#Testpass123#',
            name='Test Name',
        )
        logIn(user)
        credentials = base64.b64encode(
            b'basic@example.com:Testpass123#Testpass123#').decode()

        client = APIClient()
        res = client.get(ME_URL, HTTP_AUTHORIZATION=f'Basic {credentials}')

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
