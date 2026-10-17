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

from core.models import (IsSecurityAdmin, IsLogged, getAdminRole,
                         getAssistantRole, isSecurityAdmin)
from django.contrib.auth import login, logout
from django.contrib.auth.models import AnonymousUser
from core.models import Session, logIn, logOut
from core.utils import LogInThrottle

from django.contrib.auth import get_user_model

from user.serializers import (
    AuthTokenSerializer,
    UserSerializer,
    AssistanSerializer,
    AdminSerializer,
    ManageUserSerializer,
    SessionSerializer,
    HealthCheckSerializer,
)

from user.filters import UserFilter

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



class CreateLabAssistantView(generics.CreateAPIView):
    serializer_class = AssistanSerializer
    permission_classes = [permissions.IsAuthenticated, IsSecurityAdmin, IsLogged]


class CreateLabAdminView(generics.CreateAPIView):
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
            # Mismo mensaje si el código no existe, la contraseña es
            # incorrecta o la cuenta está desactivada (D12).
            return Response({'message': LOGIN_FAILED_MESSAGE},
                            status=status.HTTP_401_UNAUTHORIZED)

        login(request, user)
        logIn(request.user)
        response_serializer  = UserSerializer(instance = user)
        #response_serializer.is_valid(raise_exception=True)
        return Response(data = response_serializer.data, status=status.HTTP_200_OK)



from django.views.decorators.csrf import csrf_exempt


class LogoutView(generics.CreateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated, IsLogged]
    def post(self, request, *args, **kwargs):
        # Perform logout logic here
        if(isinstance(request.user, AnonymousUser)):
            return Response(status=status.HTTP_412_PRECONDITION_FAILED)

        logout(request)  # Delete user's auth token
        logOut(request.user)


        return Response(status=status.HTTP_202_ACCEPTED)


class UserProfileView(generics.RetrieveUpdateAPIView):
    """Manage the authenticated user."""
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated, IsLogged]

    def get_object(self):
        """Retrieve and return the authenticated user."""
        return self.request.user


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



class HealthCheck(views.APIView):
    serializer_class = HealthCheckSerializer
    def get(self, request, *args, **kargs):
        return Response({'status':'OK'}, status=status.HTTP_200_OK)




class MissingQueryParameterException(exceptions.APIException):
    status_code = 400
    default_detail = 'Falta un parámetro query.'
    default_code = 'missing_query_parameter'

