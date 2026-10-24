from datetime import timedelta

from django.db import transaction
from django.utils import timezone
from rest_framework import serializers
from .models import Prestamo, PrestamoItem
from item.serializers import ItemSerializer
from django.contrib.auth import get_user_model
from item.models import Item
from core.permissions import has_permission

User = get_user_model()

# Quien tiene este permiso ve y cierra los préstamos de todos; los demás,
# solo los propios.
SEE_ALL_LOANS = 'ver_todos_prestamos'


# Plazo máximo de un préstamo; el calendario de la aplicación usa el mismo.
MAX_LOAN_DAYS = 90


class PrestamoItemSerializer(serializers.ModelSerializer):
    item_id = serializers.PrimaryKeyRelatedField(queryset = Item.objects.all(), many = False, source = 'item')
    cantidad = serializers.IntegerField(min_value=1)
    class Meta:
        model = PrestamoItem
        fields = ['item_id', 'cantidad']


class PrestamoSerializer(serializers.ModelSerializer):
    items = PrestamoItemSerializer(source = 'prestamoitem_set', many=True)
    usuario = serializers.StringRelatedField()  # Para la serialización

    class Meta:
        model = Prestamo
        fields = ['id', 'usuario', 'fecha_prestamo', 'fecha_devolucion', 'devuelto', 'items']
        # La fecha de préstamo la pone el servidor: si la mandara el
        # cliente, se podrían registrar préstamos con fechas pasadas.
        read_only_fields = ['fecha_prestamo']

    def validate_items(self, items):
        if not items:
            raise serializers.ValidationError('El préstamo debe tener al menos un equipo.')
        ids = [entry['item'].pk for entry in items]
        if len(ids) != len(set(ids)):
            raise serializers.ValidationError('Cada equipo debe aparecer una sola vez; sume las unidades.')
        return items

    def validate_fecha_devolucion(self, value):
        if self.instance is not None:
            return value
        now = timezone.now()
        if value <= now:
            raise serializers.ValidationError('La fecha de devolución debe ser futura.')
        if value > now + timedelta(days=MAX_LOAN_DAYS):
            raise serializers.ValidationError(
                f'Un préstamo dura como máximo {MAX_LOAN_DAYS} días.')
        return value

    # Si falla la validación de un ítem, se revierte todo el préstamo y su
    # efecto en el stock.
    @transaction.atomic
    def create(self, validated_data):
        items_data = validated_data.pop('prestamoitem_set')
        # Un préstamo nace en curso; se devuelve después.
        validated_data.pop('devuelto', None)
        usuario = self.context['request'].user
        prestamo = Prestamo.objects.create(
            usuario=usuario, fecha_prestamo=timezone.now(), **validated_data)
        for item_data in items_data:
            item = item_data['item']
            PrestamoItem.objects.create(prestamo=prestamo, item=item, cantidad=item_data['cantidad'])
        return prestamo

    @transaction.atomic
    def update(self, instance, validated_data):
        """Un préstamo registrado solo cambia de en curso a devuelto.

        Las fechas y los equipos no se editan (el usuario podría alargar su
        propio plazo), y un préstamo devuelto no se reabre: volvería a
        reservar unidades que quizá ya se prestaron a otra persona.
        """
        request = self.context['request']

        if instance.usuario != request.user \
                and not has_permission(request, SEE_ALL_LOANS):
            raise serializers.ValidationError("No tiene permiso para editar este préstamo.")

        devuelto = validated_data.get('devuelto', instance.devuelto)
        if instance.devuelto and not devuelto:
            raise serializers.ValidationError(
                {'devuelto': 'Un préstamo devuelto no se puede reabrir.'})

        if devuelto and not instance.devuelto:
            for prestamo_item in instance.prestamoitem_set.all():
                item = Item.objects.select_for_update().get(pk=prestamo_item.item_id)
                item.quantity_on_loan -= prestamo_item.cantidad
                item.save()
            instance.devuelto = True
            instance.save()

        return instance
