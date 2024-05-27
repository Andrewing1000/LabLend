
import os
import uuid


from django.db import models
from django.core.exceptions import ValidationError

def item_image_file_path(instance, filename):
    """Generate file path for new image"""
    ext = os.path.splitext(filename)[1]
    filename = f'{uuid.uuid4}{ext}'

    return os.path.join('uploads', 'item', filename)


class Brand(models.Model):
    marca = models.CharField(max_length=100, blank=False, null=False)

    def clean(self):
        if self.marca.strip() == "":
            raise ValidationError({'marca': 'Este campo no puede estar vacío.'})

    def save(self, *args, **kwargs):
        self.full_clean()  # Validate the model instance
        super().save(*args, **kwargs)

    def __str__(self):
        return self.marca


class Category(models.Model):
    nombre = models.CharField(max_length=100, blank=False, null=False)
    description = models.TextField(blank=True)

    def clean(self):
        if self.nombre.strip() == "":
            raise ValidationError({'nombre': 'Este campo no puede estar vacío.'})

    def save(self, *args, **kwargs):
        self.full_clean()  # Validate the model instance
        super().save(*args, **kwargs)

    def __str__(self):
        return self.nombre


class Item(models.Model):
    """Objeto de laboratorio."""
    marca = models.ForeignKey(Brand, null=True, on_delete=models.SET_NULL)
    categories = models.ManyToManyField(Category, related_name='items')

    nombre = models.CharField(max_length=255, blank=False, null=False)
    description = models.TextField(blank=True)
    link = models.CharField(max_length=255, blank=True)
    serial_number = models.CharField(max_length=100, blank=True)
    quantity = models.PositiveIntegerField(default=1)
    image = models.ImageField(null=True, blank=True, upload_to=item_image_file_path)

    def clean(self):
        if self.nombre.strip() == "":
            raise ValidationError({'nombre': 'Este campo no puede estar vacío.'})

    def save(self, *args, **kwargs):
        self.full_clean()  # Validate the model instance
        super().save(*args, **kwargs)

    def __str__(self):
        return self.nombre
