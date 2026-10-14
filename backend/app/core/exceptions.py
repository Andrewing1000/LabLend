"""
API exception handling.
"""
import logging

from django.core.exceptions import NON_FIELD_ERRORS
from django.core.exceptions import ValidationError as DjangoValidationError
from rest_framework import status
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.serializers import as_serializer_error
from rest_framework.settings import api_settings
from rest_framework.views import exception_handler, set_rollback

logger = logging.getLogger(__name__)


def api_exception_handler(exc, context):
    """Return validation errors as 400 and hide internal errors."""
    if isinstance(exc, DjangoValidationError):
        # Validaciones de los modelos (full_clean) en lugar de un error 500.
        detail = as_serializer_error(exc)
        if NON_FIELD_ERRORS in detail:
            detail[api_settings.NON_FIELD_ERRORS_KEY] = detail.pop(
                NON_FIELD_ERRORS)
        exc = ValidationError(detail)

    response = exception_handler(exc, context)
    if response is not None:
        return response

    # Error inesperado: se registra en el servidor sin exponer detalles.
    view = context.get('view')
    logger.error(
        'Error inesperado en %s',
        view.__class__.__name__ if view else 'API',
        exc_info=exc,
    )
    set_rollback()
    return Response(
        {'detail': 'Error interno del servidor.'},
        status=status.HTTP_500_INTERNAL_SERVER_ERROR,
    )
