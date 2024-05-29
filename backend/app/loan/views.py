from rest_framework import viewsets
from rest_framework.exceptions import PermissionDenied

from loan.models import Prestamo
from loan.serializers import PrestamoSerializer
from rest_framework import permissions
from core.models import IsLogged, IsLabAdmin, isAdmin

from loan.filters import PrestamoFilter

class PrestamoViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated, IsLogged]
    queryset = Prestamo.objects.all()
    serializer_class = PrestamoSerializer
    filterset_class = PrestamoFilter

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    def get_object(self):
        instance = super().get_object()
        if instance.usuario != self.request.user and not isAdmin(self.request.user):
            raise PermissionDenied("No tiene permiso para ver este préstamo.")

        return instance

    def get_queryset(self):
        queryset = super().get_queryset()
        if not isAdmin(self.request.user):
            return queryset.filter(usuario=self.request.user).order_by('fecha_devolucion')
        return queryset

