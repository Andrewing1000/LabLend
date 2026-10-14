# urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import BrandViewSet, CategoryViewSet, ItemViewSet, ListItemsView, ListBrandsView, ListCategoriesView

router = DefaultRouter()
router.register(r'brands', BrandViewSet)
router.register(r'categories', CategoryViewSet)
router.register(r'items', ItemViewSet)
router.register(r'list/categories', ListCategoriesView,
                basename='list-category')
router.register(r'list/brands', ListBrandsView, basename='list-brand')
router.register(r'list/items', ListItemsView, basename='list-item')
urlpatterns = [
    path('', include(router.urls)),
]
