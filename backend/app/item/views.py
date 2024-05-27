# views.py
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets
from .models import Brand, Category, Item
from .serializers import BrandSerializer, CategorySerializer, ItemSerializer
from .filters import ItemFilter

class BrandViewSet(viewsets.ModelViewSet):
    queryset = Brand.objects.all()
    serializer_class = BrandSerializer

class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

class ItemViewSet(viewsets.ModelViewSet):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer
    filter_backends = (DjangoFilterBackend,)
    filterset_class = ItemFilter
