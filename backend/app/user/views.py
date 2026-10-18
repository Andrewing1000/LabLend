"""
Views for the user API.
"""
from rest_framework import generics, views, permissions, exceptions
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework.response import Response
from rest_framework.settings import api_settings
from rest_framework import pagination
from rest_framework import status

from core.models import (IsSecurityAdmin, IsLogged, PasswordLink,
                         SecurityEvent,
                         getAdminRole, getAssistantRole, isSecurityAdmin,
                         roleName)
from core.audit import record_event, safe_attempted_username
from django.contrib.auth import login, logout
from django.contrib.auth.models import AnonymousUser
from core.models import Session, logIn, logOut
from core.passwords import (create_password_link, find_valid_link,
                            link_url,
                            use_link)
from core.utils import CurrentPasswordThrottle, LogInThrottle

from django.contrib.auth import get_user_model

from user.serializers import (
    AuthTokenSerializer,
    UserSerializer,
    AssistanSerializer,
    AdminSerializer,
    ManageUserSerializer,
    PasswordLinkSerializer,
    PasswordLinkUseSerializer,
    ProfileSerializer,
    ResetLinkRequestSerializer,
    SecurityEventSerializer,
    SessionSerializer,
    HealthCheckSerializer,
)

from user.filters import SecurityEventFilter, UserFilter

from django.core.exceptions import ValidationError as DjangoValidationError
from django.shortcuts import get_object_or_404

from drf_spectacular.utils import extend_schema
from drf_spectacular.openapi import OpenApiParameter
from drf_spectacular.types import OpenApiTypes

LOGIN_FAILED_MESSAGE = 'Código de usuario o contraseña incorrectos'

class UserListPagination(pagination.CursorPagination):
    page_size = 10
    ordering = 'email'
    cursor_query_param = 'cursor'
    page_size_query_param = 'page_size'
    max_page_size = 100

    def get_paginated_response(self, data):
        return super().get_paginated_response(data)


class LogListPagination(pagination.CursorPagination):
    ordering = 'login_time'
    cursor_query_param = 'cursor'
    page_size_query_param = 'page_size'
    max_page_size = 100

    def get_paginated_response(self, data):
        return super().get_paginated_response(data)


class ListUsersView(generics.ListAPIView):
    """List shows users in the api"""
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated, IsSecurityAdmin, IsLogged]
    #pagination_class = UserListPagination
    queryset = get_user_model().objects.all().order_by('email')
    filterset_class = UserFilter

    def get_queryset(self):

        admin_param = self.request.query_params.get('is_admin', None)
        queryset = self.queryset
        # Filter queryset based on the 'admin' parameter
        if admin_param is not None:
            if admin_param.lower() in ['true', '1', 'yes']:
                admin = getAdminRole()
                queryset = queryset.filter(role = admin)

            elif admin_param.lower() in ['false', '0', 'no']:
                assistant = getAssistantRole()
                queryset = queryset.filter(role = assistant)

        return queryset

    @extend_schema(parameters=[
        OpenApiParameter(
            name='is_admin',
            description="Filter users by their admin status.",
            required=False,
            type=bool
        )
    ])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)


class ListUserLogsView(generics.ListAPIView):
    """List shows user logs in the api"""
    serializer_class = SessionSerializer
    permission_classes = [permissions.IsAuthenticated, IsSecurityAdmin, IsLogged]
    #pagination_class = LogListPagination
    queryset = Session.objects.all()

    def get_queryset(self):

        email = self.request.query_params.get('email', None)
        queryset = self.queryset
        # Filter queryset based on the 'admin' parameter
        if not email:
            raise MissingQueryParameterException(detail="Se debe especificar el parámetro de email.")

        email = get_user_model().objects.normalize_email(email)
        user = get_object_or_404(get_user_model(), email = email)

        queryset = queryset.filter(user = user)

        return queryset

    @extend_schema(parameters=[
        OpenApiParameter(
            name='email',
            description="Email from which user log is going to be returned.",
            required=True,
            type=OpenApiTypes.STR
        )
    ])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)



# Datos de la cuenta que se comparan para registrar qué cambió (D28).
# La contraseña nunca se compara ni se registra: solo si cambió.
ACCOUNT_FIELDS = ['email', 'nombres', 'apellido_paterno', 'apellido_materno',
                  'is_active']


def account_snapshot(user):
    data = {field: getattr(user, field) for field in ACCOUNT_FIELDS}
    data['rol'] = roleName(user)
    return data


def account_changes(before, after):
    """{field: [before, after]} for the fields that changed."""
    return {field: [before[field], after[field]]
            for field in before if before[field] != after[field]}


class CreateAccountMixin:
    """Create an account without a password and return its activation
    link once (D26). Every creation is in the security event log."""

    def perform_create(self, serializer):
        super().perform_create(serializer)
        record_event(SecurityEvent.ACCOUNT_CREATED, self.request,
                     target=serializer.instance,
                     rol=roleName(serializer.instance))
        self.activation_link = issue_password_link(self.request,
                                                   serializer.instance)

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        response.data['activation_link'] = self.activation_link
        response['Cache-Control'] = 'no-store'
        return response


class SecurityEventPagination(pagination.LimitOffsetPagination):
    default_limit = 100
    max_limit = 500


class ListSecurityEventsView(generics.ListAPIView):
    """Security event log (D28): read-only, for the security admin.

    There is no endpoint to edit or delete events.
    """
    serializer_class = SecurityEventSerializer
    permission_classes = [permissions.IsAuthenticated, IsSecurityAdmin, IsLogged]
    pagination_class = SecurityEventPagination
    queryset = SecurityEvent.objects.all()
    filterset_class = SecurityEventFilter


class CreateLabAssistantView(CreateAccountMixin, generics.CreateAPIView):
    serializer_class = AssistanSerializer
    permission_classes = [permissions.IsAuthenticated, IsSecurityAdmin, IsLogged]


class CreateLabAdminView(CreateAccountMixin, generics.CreateAPIView):
    serializer_class = AdminSerializer
    permission_classes = [permissions.IsAuthenticated, IsSecurityAdmin, IsLogged]


class CreateTokenView(ObtainAuthToken):
    """Create a new auth toker for user."""
    serializer_class = AuthTokenSerializer
    throttle_classes = [LogInThrottle]
    renderer_classes = api_settings.DEFAULT_RENDERER_CLASSES


    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)


        user = serializer.validated_data.get('user')

        if not user:
            self.record_failed_login(SecurityEvent.LOGIN_FAILED,
                                     serializer.validated_data['username'])
            # Mismo mensaje si el código no existe, la contraseña es
            # incorrecta o la cuenta está desactivada (D12).
            return Response({'message': LOGIN_FAILED_MESSAGE},
                            status=status.HTTP_401_UNAUTHORIZED)

        login(request, user)
        logIn(request.user)
        record_event(SecurityEvent.LOGIN, request, actor=user)
        response_serializer  = UserSerializer(instance = user)
        #response_serializer.is_valid(raise_exception=True)
        return Response(data = response_serializer.data, status=status.HTTP_200_OK)

    def throttled(self, request, wait):
        """Record logins rejected by the attempt limit, then answer 429."""
        self.record_failed_login(SecurityEvent.LOGIN_THROTTLED,
                                 request.data.get('username', ''))
        super().throttled(request, wait)

    def record_failed_login(self, event_type, typed_username):
        """Record a failed login. The account is linked when it exists;
        otherwise the typed text is kept only if it looks like a User ID."""
        typed_username = str(typed_username or '').strip().lower()
        target = get_user_model().objects.filter(
            username=typed_username).first()
        detail = {}
        if target is None:
            detail['codigo_ingresado'] = safe_attempted_username(
                typed_username)
        record_event(event_type, self.request, target=target, **detail)



from django.views.decorators.csrf import csrf_exempt


class LogoutView(generics.CreateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated, IsLogged]
    def post(self, request, *args, **kwargs):
        # Perform logout logic here
        if(isinstance(request.user, AnonymousUser)):
            return Response(status=status.HTTP_412_PRECONDITION_FAILED)

        # Se guarda el usuario antes de logout(), que lo reemplaza por un
        # usuario anónimo: antes, la bitácora nunca registraba la salida.
        user = request.user
        record_event(SecurityEvent.LOGOUT, request, actor=user)
        logout(request)  # Delete user's auth token
        logOut(user)


        return Response(status=status.HTTP_202_ACCEPTED)


class UserProfileView(generics.RetrieveUpdateAPIView):
    """Manage the authenticated user."""
    serializer_class = ProfileSerializer
    permission_classes = [permissions.IsAuthenticated, IsLogged]
    throttle_classes = (api_settings.DEFAULT_THROTTLE_CLASSES
                        + [CurrentPasswordThrottle])

    def get_object(self):
        """Retrieve and return the authenticated user."""
        return self.request.user

    def perform_update(self, serializer):
        before = account_snapshot(serializer.instance)
        password_changed = 'password' in serializer.validated_data
        super().perform_update(serializer)

        changes = account_changes(before, account_snapshot(serializer.instance))
        if changes:
            record_event(SecurityEvent.PROFILE_UPDATED, self.request,
                         target=serializer.instance, cambios=changes)
        if password_changed:
            record_event(SecurityEvent.OWN_PASSWORD_CHANGED, self.request,
                         target=serializer.instance)


class ManageUserView(generics.RetrieveUpdateAPIView):
    """Edit user profiles"""
    serializer_class = ManageUserSerializer
    permission_classes = [permissions.IsAuthenticated, IsSecurityAdmin, IsLogged]

    @extend_schema(parameters=[
        OpenApiParameter(
            name='email',
            description="Find users by their email.",
            required=True,
            type=bool
        )
    ])
    def get_object(self):
        """Retrieve and return the user by its email."""
        email_param = self.request.query_params.get('email', None)
        if not email_param:
            raise MissingQueryParameterException(detail="Ingrese el parámetro de email")
        user = get_object_or_404(get_user_model(), email = email_param)

        # D27: las cuentas de administrador de seguridad no se modifican
        # desde la gestión de cuentas, ni la propia ni la de otro; cada uno
        # cambia sus datos desde su perfil (/user/me/).
        if self.request.method not in permissions.SAFE_METHODS \
                and isSecurityAdmin(user):
            raise exceptions.PermissionDenied(
                'Las cuentas de administrador de seguridad no se pueden '
                'modificar desde la gestión de cuentas.')
        return user

    def perform_update(self, serializer):
        before = account_snapshot(serializer.instance)
        super().perform_update(serializer)

        changes = account_changes(before, account_snapshot(serializer.instance))
        if changes:
            record_event(SecurityEvent.ACCOUNT_UPDATED, self.request,
                         target=serializer.instance, cambios=changes)



class HealthCheck(views.APIView):
    serializer_class = HealthCheckSerializer
    def get(self, request, *args, **kargs):
        return Response({'status':'OK'}, status=status.HTTP_200_OK)




class MissingQueryParameterException(exceptions.APIException):
    status_code = 400
    default_detail = 'Falta un parámetro query.'
    default_code = 'missing_query_parameter'



LINK_INVALID_MESSAGE = ('El enlace no es válido o venció. Pida uno nuevo al '
                        'administrador de seguridad.')


LINK_CREATED_EVENTS = {
    PasswordLink.RESET: SecurityEvent.RESET_LINK_CREATED,
    PasswordLink.ACTIVATION: SecurityEvent.ACTIVATION_LINK_CREATED,
}
LINK_USED_EVENTS = {
    PasswordLink.RESET: SecurityEvent.PASSWORD_RESET,
    PasswordLink.ACTIVATION: SecurityEvent.ACCOUNT_ACTIVATED,
}


def issue_password_link(request, user):
    """Create a password link for user, record it and return the data the
    security admin sees once: the link itself is never stored."""
    link, token = create_password_link(user, created_by=request.user)
    record_event(LINK_CREATED_EVENTS[link.purpose], request, target=user,
                 vence=link.expires_at.isoformat())
    return {
        'url': link_url(token),
        'purpose': link.purpose,
        'expires_at': link.expires_at,
    }


class ResetLinkView(views.APIView):
    """Generate a password link for an account (D24, D26).

    Only the security admin. An account that was never activated gets a
    new activation link; any other, a reset link. The link is in the
    response only once: the server keeps a hash of it, so it cannot be
    shown again.
    """
    serializer_class = ResetLinkRequestSerializer
    permission_classes = [permissions.IsAuthenticated, IsSecurityAdmin,
                          IsLogged]

    @extend_schema(request=ResetLinkRequestSerializer)
    def post(self, request):
        serializer = ResetLinkRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = get_object_or_404(get_user_model(),
                                 email=serializer.validated_data['email'])
        # D27: las cuentas de administrador de seguridad no se gestionan
        # aquí; un administrador de seguridad que olvidó su contraseña la
        # recupera en el servidor con changepassword.
        if isSecurityAdmin(user):
            raise exceptions.PermissionDenied(
                'No se generan enlaces para cuentas de administrador de '
                'seguridad.')
        if not user.is_active:
            raise exceptions.ValidationError(
                {'email': ['La cuenta está desactivada.']})

        response = Response({
            'username': user.username,
            **issue_password_link(request, user),
        }, status=status.HTTP_201_CREATED)
        response['Cache-Control'] = 'no-store'
        return response


class PasswordLinkCheckView(views.APIView):
    """Check a password link and show whose account it is (D24).

    Public: whoever has the link is not logged in. The token goes in the
    body, not in the address, so it does not stay in server logs.
    """
    serializer_class = PasswordLinkSerializer
    authentication_classes = []
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = PasswordLinkSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        link = find_valid_link(serializer.validated_data['token'])
        if link is None:
            return Response({'detail': LINK_INVALID_MESSAGE},
                            status=status.HTTP_400_BAD_REQUEST)
        return Response({'username': link.user.username,
                         'purpose': link.purpose})


class PasswordLinkUseView(views.APIView):
    """Choose a password with a reset (D24) or activation (D26) link."""
    serializer_class = PasswordLinkUseSerializer
    authentication_classes = []
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = PasswordLinkUseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            link = use_link(serializer.validated_data['token'],
                            serializer.validated_data['password'])
        except DjangoValidationError as error:
            return Response({'password': list(error.messages)},
                            status=status.HTTP_400_BAD_REQUEST)
        if link is None:
            return Response({'detail': LINK_INVALID_MESSAGE},
                            status=status.HTTP_400_BAD_REQUEST)

        record_event(LINK_USED_EVENTS[link.purpose], request,
                     actor=link.user, target=link.user)
        return Response({'detail': 'Contraseña guardada. Ya puede iniciar '
                                   'sesión con su código de usuario.'})
