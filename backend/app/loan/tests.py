"""
Tests for the loan API.
"""
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from core.models import logIn
from item.models import Brand, Item
from loan.models import Prestamo
from loan.views import PrestamoViewSet

LOANS_URL = reverse('prestamo-list')


def loan_detail_url(loan_id):
    return reverse('prestamo-detail', args=[loan_id])


class LoanAPITests(TestCase):
    """Test loan creation, validation errors and error handling."""

    def setUp(self):
        self.user = get_user_model().objects.create_lab_admin(
            email='prestamos@example.com',
            password='Testpass123#Testpass123#',
            nombres='Test', apellido_paterno='Name',
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
        logIn(self.user)

        brand = Brand.objects.create(marca='Fluke')
        self.item1 = Item.objects.create(nombre='Multimetro', marca=brand,
                                         quantity=2)
        self.item2 = Item.objects.create(nombre='Osciloscopio', marca=brand,
                                         quantity=1)

    def loan_payload(self, items, start='2026-10-14T10:00:00Z',
                     end='2026-10-15T10:00:00Z'):
        return {
            'fecha_prestamo': start,
            'fecha_devolucion': end,
            'devuelto': False,
            'items': items,
        }

    def test_create_loan_updates_stock(self):
        """Test creating a valid loan succeeds and reserves the units."""
        payload = self.loan_payload([{'item_id': self.item1.id,
                                      'cantidad': 1}])

        res = self.client.post(LOANS_URL, payload, format='json')

        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.item1.refresh_from_db()
        self.assertEqual(self.item1.quantity_on_loan, 1)

    def test_return_date_before_loan_date_returns_400(self):
        """Test an invalid date range is a 400 with the field error."""
        payload = self.loan_payload(
            [{'item_id': self.item1.id, 'cantidad': 1}],
            start='2026-10-15T10:00:00Z',
            end='2026-10-14T10:00:00Z',
        )

        res = self.client.post(LOANS_URL, payload, format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('fecha_devolucion', res.data)
        self.assertFalse(Prestamo.objects.exists())

    def test_insufficient_stock_rolls_back_whole_loan(self):
        """Test a failing item leaves no loan and no stock change."""
        payload = self.loan_payload([
            {'item_id': self.item1.id, 'cantidad': 1},
            {'item_id': self.item2.id, 'cantidad': 5},
        ])

        res = self.client.post(LOANS_URL, payload, format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('non_field_errors', res.data)
        self.assertFalse(Prestamo.objects.exists())
        self.item1.refresh_from_db()
        self.assertEqual(self.item1.quantity_on_loan, 0)

    def test_invalid_update_keeps_stock(self):
        """Test a rejected return does not release the loaned units."""
        payload = self.loan_payload([{'item_id': self.item1.id,
                                      'cantidad': 1}])
        loan_id = self.client.post(LOANS_URL, payload,
                                   format='json').data['id']

        res = self.client.patch(
            loan_detail_url(loan_id),
            {'devuelto': True, 'fecha_devolucion': '2026-10-13T10:00:00Z'},
            format='json',
        )

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.item1.refresh_from_db()
        self.assertEqual(self.item1.quantity_on_loan, 1)
        self.assertFalse(Prestamo.objects.get(id=loan_id).devuelto)

    def test_unexpected_error_hides_details(self):
        """Test an unexpected error is logged and returns a generic 500."""
        with patch.object(PrestamoViewSet, 'list',
                          side_effect=RuntimeError('detalle interno')):
            with self.assertLogs('core.exceptions', level='ERROR') as logs:
                res = self.client.get(LOANS_URL)

        self.assertEqual(res.status_code,
                         status.HTTP_500_INTERNAL_SERVER_ERROR)
        self.assertEqual(res.data, {'detail': 'Error interno del servidor.'})
        self.assertNotIn('detalle interno', res.content.decode())
        self.assertIsInstance(logs.records[0].exc_info[1], RuntimeError)
