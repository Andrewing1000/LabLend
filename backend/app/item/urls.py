# urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import BrandViewSet, CategoryViewSet, ItemViewSet, ListItemsView, ListBrandsView, ListCategoriesView

router = DefaultRouter()
router.register(r'brands', BrandViewSet)
router.register(r'categories', CategoryViewSet)
router.register(r'items', ItemViewSet)
router.register(r'list/categories', ListCategoriesView)
router.register(r'list/brands', ListBrandsView)
router.register(r'list/items', ListItemsView)
urlpatterns = [
    path('', include(router.urls)),
]
