from rest_framework import serializers
from .models import Prestamo, PrestamoItem
from item.serializers import ItemSerializer
from django.contrib.auth import get_user_model
from item.models import Item
from core.models import IsLabAdmin, LAB_ADMIN

User = get_user_model()

class PrestamoItemSerializer(serializers.ModelSerializer):
    item = serializers.PrimaryKeyRelatedField(queryset=Item.objects.all())

    class Meta:
        model = PrestamoItem
        fields = ['item', 'cantidad']

class PrestamoSerializer(serializers.ModelSerializer):
    items = PrestamoItemSerializer(many=True)
    usuario = serializers.StringRelatedField()  # Para la serialización

    class Meta:
        model = Prestamo
        fields = ['id', 'usuario', 'fecha_prestamo', 'fecha_devolucion', 'devuelto', 'items']

    def create(self, validated_data):
        items_data = validated_data.pop('items')
        usuario = self.context['request'].user
        prestamo = Prestamo.objects.create(usuario=usuario, **validated_data)
        for item_data in items_data:
            item = item_data['item']
            print("----------------->"+ repr(item))
            PrestamoItem.objects.create(prestamo=prestamo, item=item, cantidad=item_data['cantidad'])
        return prestamo

    def update(self, instance, validated_data):
        request = self.context['request']
        user = request.user
        isAdmin = user.is_superuser or (hasattr(user, 'role') and user.role.role_name == LAB_ADMIN)

        if instance.usuario != user and not isAdmin:
            raise serializers.ValidationError("No tiene permiso para editar este préstamo.")

        items_data = validated_data.pop('items', None)
        instance.fecha_prestamo = validated_data.get('fecha_prestamo', instance.fecha_prestamo)
        instance.fecha_devolucion = validated_data.get('fecha_devolucion', instance.fecha_devolucion)
        instance.devuelto = validated_data.get('devuelto', instance.devuelto)

        # Si el préstamo ha sido marcado como devuelto, actualizar la cantidad en préstamo de cada ítem
        if instance.devuelto:
            for prestamo_item in instance.prestamoitem_set.all():
                prestamo_item.item.quantity_on_loan -= prestamo_item.cantidad
                prestamo_item.item.save()

        instance.save()

        if items_data is not None:
            # Clear previous items
            instance.prestamoitem_set.all().delete()
            for item_data in items_data:
                item = item_data['item']
                PrestamoItem.objects.create(prestamo=instance, item=item, cantidad=item_data['cantidad'])

        return instance
