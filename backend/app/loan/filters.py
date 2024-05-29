import django_filters
from django_filters import rest_framework as filters
from loan.models import Prestamo
from django.utils.timezone import make_aware
from datetime import datetime

class PrestamoFilter(filters.FilterSet):
    start_date = filters.DateFilter(field_name='fecha_prestamo', method='filter_start_date', label='Fecha de Préstamo (Desde)')
    end_date = filters.DateFilter(field_name='fecha_prestamo', method='filter_end_date', label='Fecha de Préstamo (Hasta)')
    devuelto = filters.BooleanFilter(field_name='devuelto')

    class Meta:
        model = Prestamo
        fields = ['start_date', 'end_date', 'devuelto']

    def filter_start_date(self, queryset, name, value):
        if value:
            value = make_aware(datetime.combine(value, datetime.min.time()))
            queryset = queryset.filter(fecha_prestamo__gte=value)
        return queryset

    def filter_end_date(self, queryset, name, value):
        if value:
            value = make_aware(datetime.combine(value, datetime.max.time()))
            queryset = queryset.filter(fecha_prestamo__lte=value)
        return queryset

    def filter_queryset(self, queryset):
        queryset = super().filter_queryset(queryset)
        if 'start_date' in self.data or 'end_date' in self.data:
            start_date = self.data.get('start_date')
            end_date = self.data.get('end_date')
            if start_date:
                start_date = make_aware(datetime.combine(datetime.fromisoformat(start_date), datetime.min.time()))
                queryset = queryset.filter(fecha_prestamo__gte=start_date)
            if end_date:
                end_date = make_aware(datetime.combine(datetime.fromisoformat(end_date), datetime.max.time()))
                queryset = queryset.filter(fecha_prestamo__lte=end_date)
        return queryset
