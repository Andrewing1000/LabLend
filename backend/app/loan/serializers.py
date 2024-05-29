from rest_framework import serializers
from .models import Prestamo, PrestamoItem
from item.serializers import ItemSerializer
from django.contrib.auth import get_user_model
from item.models import Item
from core.models import IsLabAdmin, isAdmin

User = get_user_model()

class PrestamoItemSerializer(serializers.ModelSerializer):
    item_id = serializers.PrimaryKeyRelatedField(queryset = Item.objects.all(), many = False, source = 'item')
    cantidad = serializers.IntegerField()
    class Meta:
        model = PrestamoItem
        fields = ['item_id', 'cantidad']


class PrestamoSerializer(serializers.ModelSerializer):
    items = PrestamoItemSerializer(source = 'prestamoitem_set', many=True)
    usuario = serializers.StringRelatedField()  # Para la serialización

    class Meta:
        model = Prestamo
        fields = ['id', 'usuario', 'fecha_prestamo', 'fecha_devolucion', 'devuelto', 'items']

    def create(self, validated_data):
        items_data = validated_data.pop('prestamoitem_set')
        usuario = self.context['request'].user
        prestamo = Prestamo.objects.create(usuario=usuario, **validated_data)
        for item_data in items_data:
            item = item_data['item']
            PrestamoItem.objects.create(prestamo=prestamo, item=item, cantidad=item_data['cantidad'])
        return prestamo

    def update(self, instance, validated_data):
        request = self.context['request']

        if instance.usuario != request.user and not isAdmin(request.user):
            raise serializers.ValidationError("No tiene permiso para editar este préstamo.")

        items_data = validated_data.pop('items', None)
        instance.fecha_prestamo = validated_data.get('fecha_prestamo', instance.fecha_prestamo)
        instance.fecha_devolucion = validated_data.get('fecha_devolucion', instance.fecha_devolucion)

        devuelto = validated_data.get('devuelto', instance.devuelto)


        if devuelto and not instance.devuelto:
            for prestamo_item in instance.prestamoitem_set.all():
                prestamo_item.item.quantity_on_loan -= prestamo_item.cantidad
                prestamo_item.item.save()


        if not devuelto and instance.devuelto:
            for prestamo_item in instance.prestamoitem_set.all():
                prestamo_item.item.quantity_on_loan += prestamo_item.cantidad
                prestamo_item.item.save()

        instance.devuelto = devuelto
        instance.save()

        if items_data is not None:
            # Clear previous items
            instance.prestamoitem_set.all().delete()
            for item_data in items_data:
                item = item_data['item_id']
                PrestamoItem.objects.create(prestamo=instance, item=item, cantidad=item_data['cantidad'])

        return instance
