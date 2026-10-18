# views.py
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets, status, generics
from .models import Brand, Category, Item
from .serializers import BrandSerializer, CategorySerializer, ItemSerializer, ItemImageSerializer
from .filters import ItemFilter

from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework import permissions

class BrandViewSet(viewsets.ModelViewSet):
    required_permission = 'gestionar_inventario'
    queryset = Brand.objects.all()
    serializer_class = BrandSerializer

class CategoryViewSet(viewsets.ModelViewSet):
    required_permission = 'gestionar_inventario'
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

class ItemViewSet(viewsets.ModelViewSet):
    required_permission = 'gestionar_inventario'
    queryset = Item.objects.all()
    serializer_class = ItemSerializer
    filterset_class = ItemFilter


    def get_serializer_class(self):
        if self.action == 'upload_image':
            return ItemImageSerializer
        return self.serializer_class

    @action(methods=['POST'], detail=True, url_path='upload-image')
    def upload_image(self, request, pk = None):
        item = self.get_object()
        serializer = self.get_serializer(item, data = request.data)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Catálogo público: lo consulta cualquiera, incluso sin sesión.

class ListBrandsView(viewsets.ReadOnlyModelViewSet):
    permission_classes = [permissions.AllowAny]
    queryset = Brand.objects.all()
    serializer_class = BrandSerializer


class ListCategoriesView(viewsets.ReadOnlyModelViewSet):
    permission_classes = [permissions.AllowAny]
    queryset = Category.objects.all()
    serializer_class = CategorySerializer


class ListItemsView(viewsets.ReadOnlyModelViewSet):
    permission_classes = [permissions.AllowAny]
    queryset = Item.objects.all()
    serializer_class = ItemSerializer
    filterset_class = ItemFilter
