# serializers.py
from django.db import transaction
from rest_framework import serializers
from .models import Brand, Category, Item
import logging

def _unique_name(model, field, value, instance):
    """Rechaza un nombre que ya existe, sin distinguir mayúsculas."""
    value = value.strip()
    others = model.objects.filter(**{f'{field}__iexact': value})
    if instance is not None:
        others = others.exclude(pk=instance.pk)
    if others.exists():
        raise serializers.ValidationError('Ya existe con ese nombre.')
    return value


class BrandSerializer(serializers.ModelSerializer):
    class Meta:
        model = Brand
        fields = ['id', 'marca']

    def validate_marca(self, value):
        # Dentro de un equipo la marca se elige o se crea por nombre: ahí
        # repetirla es lo normal.
        if self.parent is not None:
            return value.strip()
        return _unique_name(Brand, 'marca', value, self.instance)


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'nombre', 'description']

    def validate_nombre(self, value):
        if self.parent is not None:
            return value.strip()
        return _unique_name(Category, 'nombre', value, self.instance)


def _brand_for(data):
    """La marca con ese nombre (sin distinguir mayúsculas), o una nueva."""
    brand = Brand.objects.filter(marca__iexact=data['marca']).first()
    return brand or Brand.objects.create(marca=data['marca'])


def _category_for(data):
    """La categoría con ese nombre. La descripción no cuenta: con una copia
    vieja de la descripción se creaba otra categoría con el mismo nombre."""
    category = Category.objects.filter(nombre__iexact=data['nombre']).first()
    return category or Category.objects.create(
        nombre=data['nombre'], description=data.get('description', ''))


class ItemSerializer(serializers.ModelSerializer):
    marca = BrandSerializer()
    categories = CategorySerializer(many=True)

    class Meta:
        model = Item
        fields = ['id', 'nombre', 'description', 'link', 'marca', 'categories', 'serial_number', 'quantity', 'quantity_on_loan', "image"]
        extra_kwargs = {
             'quantity_on_loan' : {'read_only': True},
             'image' : {'read_only': True},
        }

    def validate_quantity(self, value):
        # No se pueden quitar unidades que están prestadas.
        if self.instance is not None and value < self.instance.quantity_on_loan:
            raise serializers.ValidationError(
                f'Hay {self.instance.quantity_on_loan} unidades prestadas; '
                'la cantidad no puede ser menor.')
        return value

    @transaction.atomic
    def create(self, validated_data):
        marca_data = validated_data.pop('marca')
        categories_data = validated_data.pop('categories')
        item = Item.objects.create(marca=_brand_for(marca_data), **validated_data)
        item.categories.set([_category_for(c) for c in categories_data])
        return item

    @transaction.atomic
    def update(self, instance, validated_data):
        # En un PATCH la marca y las categorías pueden no venir.
        marca_data = validated_data.pop('marca', None)
        categories_data = validated_data.pop('categories', None)
        if marca_data is not None:
            instance.marca = _brand_for(marca_data)
        for field in ['nombre', 'description', 'link', 'serial_number', 'quantity']:
            setattr(instance, field, validated_data.get(field, getattr(instance, field)))
        instance.save()

        if categories_data is not None:
            instance.categories.set([_category_for(c) for c in categories_data])

        return instance


class ItemImageSerializer(serializers.ModelSerializer):
    """Serializer for uploading images to lab items."""

    class Meta:
        model = Item
        fields = ['id', 'image']
        read_only_fields = ['id']
        extra_kwargs = {
            'image' : {'required' : True, 'allow_null': False}
        }
