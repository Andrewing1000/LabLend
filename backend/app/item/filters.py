
from django_filters import rest_framework as filters
from django.contrib.postgres.search import TrigramSimilarity
from item.models import Item, Category, Brand
import logging

class ItemFilter(filters.FilterSet):
    categories = filters.ModelMultipleChoiceFilter(queryset=Category.objects.all(), field_name='categories__id', to_field_name='id')
    marca = filters.ModelChoiceFilter(queryset=Brand.objects.all(), field_name='marca_id', to_field_name='id')
    name = filters.CharFilter(method='filter_by_name')

    class Meta:
        model = Item
        fields = ['categories', 'marca', 'name']

    def filter_by_name(self, queryset, name, value):
        return queryset.annotate(
            similarity=TrigramSimilarity('nombre', value)
        ).filter(
            similarity__gt=0.1  # Adjust threshold as needed
        ).order_by('-similarity')

    def filter_queryset(self, queryset):
        queryset = super().filter_queryset(queryset)
        return queryset
