# serializers.py
from rest_framework import serializers
from .models import Brand, Category, Item
import logging

class BrandSerializer(serializers.ModelSerializer):
    class Meta:
        model = Brand
        fields = ['id', 'marca']


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'nombre', 'description']

class ItemSerializer(serializers.ModelSerializer):
    marca = BrandSerializer()
    categories = CategorySerializer(many=True)

    class Meta:
        model = Item
        fields = ['id', 'nombre', 'description', 'link', 'marca', 'categories', 'serial_number', 'quantity', 'quantity_on_loan']
        extra_kwargs = {
             'quantity_on_loan' : {'read_only': True},
        }

    def create(self, validated_data):
        marca_data = validated_data.pop('marca')
        categories_data = validated_data.pop('categories')
        brand, created = Brand.objects.get_or_create(**marca_data)
        item = Item.objects.create(marca=brand, **validated_data)
        for category in categories_data:
            cat, created = Category.objects.get_or_create(**category)
            item.categories.add(cat)
        return item

    def update(self, instance, validated_data):
        marca_data = validated_data.pop('marca')
        categories_data = validated_data.pop('categories')
        brand, created = Brand.objects.get_or_create(**marca_data)
        instance.marca = brand
        instance.nombre = validated_data.get('nombre', instance.nombre)
        instance.description = validated_data.get('description', instance.description)
        instance.link = validated_data.get('link', instance.link)
        instance.serial_number = validated_data.get('serial_number', instance.serial_number)
        instance.quantity = validated_data.get('quantity', instance.quantity)
        instance.save()

        instance.categories.clear()
        for category in categories_data:
            cat, created = Category.objects.get_or_create(**category)
            instance.categories.add(cat)

        return instance


class ItemImageSerializer(serializers.ModelSerializer):
    """Serializer for uploading images to lab items."""

    class Meta:
        model = Item
        fields = ['id', 'image']
        read_only_fields = ['id']
        kwargs = {
            'image' : {'required' : True}
        }