from rest_framework import viewsets
from rest_framework.exceptions import PermissionDenied

from loan.models import Prestamo
from loan.serializers import SEE_ALL_LOANS, PrestamoSerializer
from core.permissions import has_permission

from loan.filters import PrestamoFilter


class PrestamoViewSet(viewsets.ModelViewSet):
    # Solo los roles del laboratorio prestan equipos: el administrador de
    # seguridad gestiona cuentas, no préstamos (D18).
    required_permission = 'registrar_prestamos'
    queryset = Prestamo.objects.all()
    serializer_class = PrestamoSerializer
    filterset_class = PrestamoFilter

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    def get_object(self):
        instance = super().get_object()
        if instance.usuario != self.request.user \
                and not has_permission(self.request, SEE_ALL_LOANS):
            raise PermissionDenied("No tiene permiso para ver este préstamo.")

        return instance

    def get_queryset(self):
        queryset = super().get_queryset()
        if not has_permission(self.request, SEE_ALL_LOANS):
            return queryset.filter(usuario=self.request.user).order_by('fecha_devolucion')
        return queryset

