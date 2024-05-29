from django.db import models
from django.core.exceptions import ValidationError
from django.contrib.auth import get_user_model
from datetime import date
from item.models import Item  # Asegúrate de que la app 'item' esté instalada y configurada

class Prestamo(models.Model):
    usuario = models.ForeignKey(get_user_model(), on_delete=models.CASCADE)
    fecha_prestamo = models.DateTimeField()
    fecha_devolucion = models.DateTimeField()
    devuelto = models.BooleanField(default=False)
    items = models.ManyToManyField(Item, through='PrestamoItem', related_name='prestamos')

    def clean(self):
        if self.fecha_devolucion <= self.fecha_prestamo:
            raise ValidationError({'fecha_devolucion': 'La fecha de devolución debe ser posterior a la fecha de préstamo.'})

        # Validar que los items no están prestados en el rango de fechas
        for prestamo_item in self.prestamoitem_set.all():
            item = prestamo_item.item
            if prestamo_item.cantidad > (item.quantity - item.quantity_on_loan):
                raise ValidationError(f'El ítem "{item.nombre}" no tiene disponibilidad suficiente para el préstamo.')

    def save(self, *args, **kwargs):
        self.full_clean()  # Validar la instancia del modelo
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Prestamo de {self.usuario.email} en {self.fecha_prestamo}"

class PrestamoItem(models.Model):
    prestamo = models.ForeignKey(Prestamo, on_delete=models.CASCADE)
    item = models.ForeignKey(Item, on_delete=models.CASCADE)
    cantidad = models.PositiveIntegerField(default=1)

    def clean(self):
        if self.cantidad > (self.item.quantity - self.item.quantity_on_loan):
            raise ValidationError(f'No hay suficiente cantidad del ítem "{self.item.nombre}" para el préstamo.')

    def save(self, *args, **kwargs):
        # Calcula la diferencia en cantidad prestada antes de la actualización


        previous_cantidad = 0
        if self.pk:
            previous_cantidad = PrestamoItem.objects.get(pk=self.pk).cantidad

        self.full_clean()  # Validar la instancia del modelo
        super().save(*args, **kwargs)



        # Actualiza la cantidad en préstamo del ítem
        difference = self.cantidad - previous_cantidad
        self.item.quantity_on_loan += difference
        self.item.save()
        print("------------------------------------------------>", type(self.item))

    def delete(self, *args, **kwargs):
        # Al eliminar, resta la cantidad prestada del campo quantity_on_loan
        self.item.quantity_on_loan -= self.cantidad
        self.item.save()
        super().delete(*args, **kwargs)
