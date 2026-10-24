"""
Tests for the loan API.
"""
from datetime import timedelta
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse
from django.utils import timezone
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

    def loan_payload(self, items, days=7):
        return {
            'fecha_devolucion': (timezone.now() + timedelta(days=days)).isoformat(),
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

    def test_return_date_in_the_past_returns_400(self):
        """Test a return date before now is a 400 with the field error."""
        payload = self.loan_payload(
            [{'item_id': self.item1.id, 'cantidad': 1}], days=-1)

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

    def create_loan(self, cantidad=1):
        payload = self.loan_payload([{'item_id': self.item1.id,
                                      'cantidad': cantidad}])
        res = self.client.post(LOANS_URL, payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        return res.data['id']

    def assert_on_loan(self, item, expected):
        item.refresh_from_db()
        self.assertEqual(item.quantity_on_loan, expected)

    def test_zero_units_rejected(self):
        """Test a line with 0 units is rejected."""
        payload = self.loan_payload([{'item_id': self.item1.id,
                                      'cantidad': 0}])

        res = self.client.post(LOANS_URL, payload, format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(Prestamo.objects.exists())

    def test_loan_without_items_rejected(self):
        """Test an empty loan is rejected."""
        res = self.client.post(LOANS_URL, self.loan_payload([]),
                               format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(Prestamo.objects.exists())

    def test_repeated_item_rejected(self):
        """Test the same item twice cannot lend more than the stock."""
        payload = self.loan_payload([
            {'item_id': self.item2.id, 'cantidad': 1},
            {'item_id': self.item2.id, 'cantidad': 1},
        ])

        res = self.client.post(LOANS_URL, payload, format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assert_on_loan(self.item2, 0)

    def test_loan_date_set_by_server(self):
        """Test the client cannot backdate a loan or create it returned."""
        payload = self.loan_payload([{'item_id': self.item1.id,
                                      'cantidad': 1}])
        payload['fecha_prestamo'] = '2020-01-01T00:00:00Z'
        payload['devuelto'] = True

        res = self.client.post(LOANS_URL, payload, format='json')

        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        loan = Prestamo.objects.get(id=res.data['id'])
        self.assertGreater(loan.fecha_prestamo,
                           timezone.now() - timedelta(minutes=1))
        self.assertFalse(loan.devuelto)
        self.assert_on_loan(self.item1, 1)

    def test_loan_longer_than_limit_rejected(self):
        """Test a return date beyond the maximum term is rejected."""
        payload = self.loan_payload(
            [{'item_id': self.item1.id, 'cantidad': 1}], days=200)

        res = self.client.post(LOANS_URL, payload, format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('fecha_devolucion', res.data)

    def test_return_releases_units_once(self):
        """Test returning twice releases the units only once."""
        loan_id = self.create_loan(2)

        for _ in range(2):
            res = self.client.patch(loan_detail_url(loan_id),
                                    {'devuelto': True}, format='json')
            self.assertEqual(res.status_code, status.HTTP_200_OK)

        self.assert_on_loan(self.item1, 0)

    def test_returned_loan_cannot_be_reopened(self):
        """Test a returned loan cannot go back to active."""
        loan_id = self.create_loan(2)
        self.client.patch(loan_detail_url(loan_id), {'devuelto': True},
                          format='json')
        # Otro préstamo toma las unidades liberadas.
        self.create_loan(2)

        res = self.client.patch(loan_detail_url(loan_id),
                                {'devuelto': False}, format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertTrue(Prestamo.objects.get(id=loan_id).devuelto)
        self.assert_on_loan(self.item1, 2)

    def test_dates_and_items_not_editable(self):
        """Test an update cannot extend the term or change the units."""
        loan_id = self.create_loan(1)
        original = Prestamo.objects.get(id=loan_id).fecha_devolucion

        res = self.client.patch(loan_detail_url(loan_id), {
            'fecha_devolucion': (timezone.now() + timedelta(days=60)).isoformat(),
            'items': [{'item_id': self.item1.id, 'cantidad': 2}],
        }, format='json')

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(Prestamo.objects.get(id=loan_id).fecha_devolucion,
                         original)
        self.assert_on_loan(self.item1, 1)

    def test_loans_cannot_be_deleted(self):
        """Test DELETE is not allowed, so reserved units never get lost."""
        loan_id = self.create_loan(1)

        res = self.client.delete(loan_detail_url(loan_id))

        self.assertEqual(res.status_code,
                         status.HTTP_405_METHOD_NOT_ALLOWED)
        self.assertTrue(Prestamo.objects.filter(id=loan_id).exists())
        self.assert_on_loan(self.item1, 1)

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
