from rest_framework import viewsets
from .models import Prestamo
from .serializers import PrestamoSerializer
from rest_framework import permissions
from core.models import IsLogged
class PrestamoViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated, IsLogged]
    queryset = Prestamo.objects.all()
    serializer_class = PrestamoSerializer
    
    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
