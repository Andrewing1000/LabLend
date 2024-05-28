# views.py
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets
from .models import Brand, Category, Item
from .serializers import BrandSerializer, CategorySerializer, ItemSerializer
from .filters import ItemFilter


from rest_framework import permissions
from core.models import IsLogged

class BrandViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated, IsLogged]
    queryset = Brand.objects.all()
    serializer_class = BrandSerializer

class CategoryViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated, IsLogged]
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

class ItemViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated, IsLogged]
    queryset = Item.objects.all()
    serializer_class = ItemSerializer
    filter_backends = (DjangoFilterBackend,)
    filterset_class = ItemFilter
