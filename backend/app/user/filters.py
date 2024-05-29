import django_filters
from django_filters import rest_framework as filters
from django.contrib.postgres.search import TrigramSimilarity
from django.db.models import Q
from core.models import User, getAdminRole, getAssistantRole


class UserFilter(filters.FilterSet):
    is_admin = filters.BooleanFilter(method='filter_by_admin_status', label='Is Admin')
    is_active = filters.BooleanFilter(field_name='is_active')
    email = filters.CharFilter(method='filter_by_email_similarity')

    class Meta:
        model = User
        fields = ['is_admin', 'is_active', 'email']

    def filter_by_admin_status(self, queryset, name, value):
        if value:
            admin_role = getAdminRole()
            return queryset.filter(Q(role=admin_role) | Q(is_staff=True))
        else:
            assistant_role = getAssistantRole()
            return queryset.filter(role=assistant_role)

    def filter_by_email_similarity(self, queryset, name, value):
        return queryset.annotate(
            similarity=TrigramSimilarity('email', value)
        ).filter(
            similarity__gt=0.1  # Adjust threshold as needed
        ).order_by('-similarity')

    def filter_queryset(self, queryset):
        queryset = super().filter_queryset(queryset)
        return queryset
