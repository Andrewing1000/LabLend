# filters.py
from django_filters import rest_framework as filters
from .models import Item, Category, Brand

class ItemFilter(filters.FilterSet):
    categories = filters.ModelMultipleChoiceFilter(queryset=Category.objects.all(), field_name='categories__id', to_field_name='id')
    brand = filters.ModelChoiceFilter(queryset=Brand.objects.all(), field_name='marca__id', to_field_name='id')
    name = filters.CharFilter(method='filter_by_name')

    class Meta:
        model = Item
        fields = ['categories', 'brand', 'name']

    def filter_by_name(self, queryset, name, value):
        return queryset.annotate(
            similarity=TrigramSimilarity('nombre', value)
        ).filter(
            similarity__gt=0.1  # Adjust threshold as needed
        ).order_by('-similarity')
