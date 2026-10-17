import django_filters
from django_filters import rest_framework as filters
from django.contrib.postgres.search import TrigramSimilarity
from django.db.models import Q
from core.models import SecurityEvent, User, getAdminRole, getAssistantRole


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
            return queryset.filter(role=admin_role)
        else:
            assistant_role = getAssistantRole()
            return queryset.filter(role=assistant_role)

    def filter_by_email_similarity(self, queryset, name, value):
        return queryset.annotate(
            similarity=TrigramSimilarity('email', value)
        ).filter(
            similarity__gt=0.0  # Adjust threshold as needed
        ).order_by('-similarity')

    def filter_queryset(self, queryset):
        queryset = super().filter_queryset(queryset)
        return queryset


class SecurityEventFilter(filters.FilterSet):
    """Filters for the security event log (D28)."""

    usuario = filters.CharFilter(method='filter_by_username',
                                 label='Código de usuario (actor o afectado)')
    tipo = filters.ChoiceFilter(field_name='event_type',
                                choices=SecurityEvent.EVENT_TYPES)
    desde = filters.DateFilter(field_name='timestamp', lookup_expr='date__gte')
    hasta = filters.DateFilter(field_name='timestamp', lookup_expr='date__lte')

    class Meta:
        model = SecurityEvent
        fields = ['usuario', 'tipo', 'desde', 'hasta']

    def filter_by_username(self, queryset, name, value):
        value = value.strip().lower()
        return queryset.filter(
            Q(actor_username=value) | Q(target_username=value)
            | Q(detail__codigo_ingresado=value))
