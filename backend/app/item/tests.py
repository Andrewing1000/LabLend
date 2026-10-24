import re

from django.test import SimpleTestCase

from item.models import item_image_file_path


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
