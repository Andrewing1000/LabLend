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

        # Validar que los items no están prestados en el rango de fechas.
        # Un préstamo nuevo aún no tiene items: cada PrestamoItem valida
        # su disponibilidad al guardarse.
        if self.pk is None:
            return
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
        if self.cantidad < 1:
            raise ValidationError({'cantidad': 'Debe prestar al menos una unidad.'})
        if self.cantidad > (self.item.quantity - self.item.quantity_on_loan):
            raise ValidationError(f'No hay suficiente cantidad del ítem "{self.item.nombre}" para el préstamo.')

    def save(self, *args, **kwargs):
        previous_cantidad = 0
        if self.pk:
            previous_cantidad = PrestamoItem.objects.get(pk=self.pk).cantidad

        # El stock se lee de nuevo y bloqueado: con una copia vieja del ítem,
        # dos líneas del mismo equipo (o dos préstamos a la vez) pasaban la
        # validación con el mismo saldo y quantity_on_loan quedaba mal.
        self.item = Item.objects.select_for_update().get(pk=self.item_id)
        if not self.prestamo.devuelto:
            # La línea ya tenía reservadas sus unidades anteriores.
            self.item.quantity_on_loan -= previous_cantidad
        self.full_clean()  # Validar la instancia del modelo
        super().save(*args, **kwargs)

        if not self.prestamo.devuelto:
            self.item.quantity_on_loan += self.cantidad
            self.item.save()

    def delete(self, *args, **kwargs):
        # Al eliminar, libera las unidades si el préstamo seguía en curso
        # (las de un préstamo devuelto ya se liberaron).
        if not self.prestamo.devuelto:
            self.item = Item.objects.select_for_update().get(pk=self.item_id)
            self.item.quantity_on_loan -= self.cantidad
            self.item.save()
        super().delete(*args, **kwargs)
