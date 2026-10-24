import re
from datetime import timedelta

from django.contrib.auth import get_user_model
from django.test import SimpleTestCase, TestCase
from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from core.models import logIn
from item.models import Brand, Category, Item, item_image_file_path
from loan.models import Prestamo, PrestamoItem


class ItemImagePathTests(SimpleTestCase):
    """Test the path where item images are stored."""

    def test_unique_uuid_name(self):
        """Test each image gets its own UUID name, keeping the extension.
        Before, the path used the uuid4 function instead of calling it, so
        every file got the same name with spaces and '<>'."""
        first = item_image_file_path(None, 'microscopio.jpg')
        second = item_image_file_path(None, 'microscopio.jpg')

        self.assertNotEqual(first, second)
        self.assertRegex(
            first,
            re.compile(r'^uploads/item/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-'
                       r'[0-9a-f]{4}-[0-9a-f]{12}\.jpg$'))


class InventoryAPITests(TestCase):
    """Test inventory rules: names, stock on loan and deletion."""

    def setUp(self):
        self.user = get_user_model().objects.create_lab_admin(
            email='inventario@example.com',
            password='Testpass123#Testpass123#',
            nombres='Test', apellido_paterno='Name',
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
        logIn(self.user)

        self.brand = Brand.objects.create(marca='Fluke')
        self.category = Category.objects.create(nombre='Medición',
                                                description='Original')
        self.item = Item.objects.create(nombre='Multimetro',
                                        marca=self.brand, quantity=5)
        self.item.categories.add(self.category)

    def item_payload(self, **changes):
        payload = {
            'nombre': 'Multimetro',
            'description': '',
            'link': '',
            'serial_number': '',
            'quantity': 5,
            'marca': {'marca': 'Fluke'},
            'categories': [{'nombre': 'Medición', 'description': 'Original'}],
        }
        payload.update(changes)
        return payload

    def lend(self, cantidad):
        loan = Prestamo.objects.create(
            usuario=self.user, fecha_prestamo=timezone.now(),
            fecha_devolucion=timezone.now() + timedelta(days=7))
        PrestamoItem.objects.create(prestamo=loan, item=self.item,
                                    cantidad=cantidad)
        return loan

    def test_duplicate_brand_rejected(self):
        """Test a brand name that exists, in any case, is rejected."""
        res = self.client.post(reverse('brand-list'), {'marca': ' FLUKE '},
                               format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(Brand.objects.count(), 1)

    def test_duplicate_category_rejected(self):
        """Test a category name that exists is rejected."""
        res = self.client.post(reverse('category-list'),
                               {'nombre': 'medición', 'description': ''},
                               format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(Category.objects.count(), 1)

    def test_old_category_description_reuses_category(self):
        """Test editing an item with a stale category description does not
        create a second category with the same name."""
        res = self.client.put(
            reverse('item-detail', args=[self.item.id]),
            self.item_payload(categories=[{'nombre': 'Medición',
                                           'description': 'Vieja'}]),
            format='json')

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(Category.objects.count(), 1)

    def test_patch_without_brand(self):
        """Test a partial update without brand or categories works."""
        res = self.client.patch(reverse('item-detail', args=[self.item.id]),
                                {'quantity': 6}, format='json')

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.item.refresh_from_db()
        self.assertEqual(self.item.quantity, 6)
        self.assertEqual(self.item.marca, self.brand)

    def test_quantity_below_units_on_loan_rejected(self):
        """Test the stock cannot drop below the units on loan."""
        self.lend(3)

        res = self.client.put(reverse('item-detail', args=[self.item.id]),
                              self.item_payload(quantity=2), format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.item.refresh_from_db()
        self.assertEqual(self.item.quantity, 5)

    def test_item_on_loan_cannot_be_deleted(self):
        """Test deleting an item with active loans is refused."""
        loan = self.lend(1)

        res = self.client.delete(reverse('item-detail', args=[self.item.id]))

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertTrue(Item.objects.filter(id=self.item.id).exists())
        self.assertEqual(loan.prestamoitem_set.count(), 1)

    def test_returned_item_can_be_deleted(self):
        """Test an item without active loans can be deleted."""
        res = self.client.delete(reverse('item-detail', args=[self.item.id]))

        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
