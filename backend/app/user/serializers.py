"""
Serializers for the user API view.
"""
from django.contrib.auth import (
    get_user_model,
    authenticate,
)
from django.contrib.auth import password_validation
from django.core.exceptions import ValidationError as DjangoValidationError
from django.utils.translation import gettext as _
from rest_framework import serializers


from core.models import (Permission, Role, Session, SecurityEvent, area_of,
                         isSecurityAccount,
                         roleNames, roles_area, username_part)
from core.permissions import has_permission
from core.rbac import SECURITY_AREA

from rest_framework.exceptions import APIException, PermissionDenied

from core.audit import record_event
from core.middleware import PASSWORD_EXPIRED_MESSAGE


def django_errors(error, field):
    """Messages of a Django ValidationError, for a DRF ValidationError."""
    if hasattr(error, 'message_dict'):
        return error.message_dict.get(field, error.messages)
    return error.messages



class SecurityRoleSegregation(APIException):
    status_code = 400
    default_detail = ('Los roles de seguridad no se pueden asignar ni quitar '
                      'a una cuenta existente: se dan solo al crearla.')
    default_code = 'roles'
    # Se registra en la bitácora de seguridad como acción rechazada (D28).
    security_event = True


from rest_framework import serializers
from django.contrib.auth import get_user_model

from rest_framework import serializers
from typing import Optional
from django.contrib.auth import get_user_model

class UserSerializer(serializers.ModelSerializer):
    """Serializer for the user object."""

    roles = serializers.SerializerMethodField()
    permissions = serializers.SerializerMethodField()
    security_account = serializers.SerializerMethodField()
    name = serializers.ReadOnlyField()
    activation_pending = serializers.BooleanField(read_only=True)
    is_locked = serializers.BooleanField(read_only=True)
    password_expired = serializers.BooleanField(read_only=True)

    class Meta:
        model = get_user_model()
        fields = ['username', 'email', 'password', 'nombres',
                  'apellido_paterno', 'apellido_materno', 'name',
                  'is_active', 'roles', 'permissions', 'security_account',
                  'activation_pending', 'is_locked', 'password_expired']
        extra_kwargs = {
            'password': {'write_only': True, 'min_length': 12},
            'email': {'required':False},
            'is_active': {'read_only': True},
        }

    def get_roles(self, obj) -> list[str]:
        """Names of the user's roles (D15)."""
        return roleNames(obj)

    def get_permissions(self, obj) -> list[str]:
        """Permissions of all the user's roles: what the app may show."""
        return sorted(obj.get_permissions())

    def get_security_account(self, obj) -> bool:
        """The account has a security role: the account management does
        not modify it (D18, D27)."""
        return isSecurityAccount(obj)

    def validate_nombres(self, value):
        """The User ID needs a letter from the first name."""
        if not username_part(value):
            raise serializers.ValidationError(
                'Los nombres deben contener al menos una letra.')
        return value

    def validate_apellido_paterno(self, value):
        """The User ID needs the letters of the paternal surname."""
        if not username_part(value):
            raise serializers.ValidationError(
                'El apellido paterno debe contener al menos una letra.')
        return value

    def validate_email(self, value):
        """The email is set when the account is created and never changes,
        neither in the own profile nor by an admin (D14). Sending the same
        email is accepted, since the app sends the whole account."""
        if self.instance is not None and value != self.instance.email:
            raise serializers.ValidationError('El correo no se puede cambiar.')
        return value

    def validate_password(self, value):
        """Apply the password policy on every creation and change."""
        try:
            password_validation.validate_password(value, user=self.instance)
        except DjangoValidationError as error:
            raise serializers.ValidationError(list(error.messages))
        return value

    def create(self, validated_data):
        """Create and return a user with encrypted password"""
        return get_user_model().objects.create_user(**validated_data)

    def update(self, instance, validated_data):
        """Update and return user."""
        password = validated_data.pop('password', None)
        user = super().update(instance, validated_data)

        if password:
            user.set_password(password)
            user.save()

        return user

class ProfileSerializer(UserSerializer):
    """Serializer for the authenticated user's own profile (/user/me/).

    Changing the password requires the current password (D14), so a
    stolen session is not enough to take over the account. The email
    cannot be changed at all (validate_email).
    """

    current_password = serializers.CharField(
        write_only=True, required=False,
        style={'input_type': 'password'}, trim_whitespace=False,
    )

    class Meta(UserSerializer.Meta):
        fields = UserSerializer.Meta.fields + ['current_password']

    def to_internal_value(self, data):
        # La contraseña actual se verifica antes que la política: si no,
        # el historial (D22) respondería si una contraseña probada es la
        # actual, sin conocerla.
        # Contraseña vencida (D21): el perfil solo acepta cambiarla.
        if self.instance.password_expired and (
                'password' not in data
                or set(data) - {'password', 'current_password'}):
            raise PermissionDenied(PASSWORD_EXPIRED_MESSAGE)
        if 'password' in data:
            self.check_current_password(data.get('current_password'))
        return super().to_internal_value(data)

    def check_current_password(self, current_password):
        if not current_password:
            raise serializers.ValidationError({'current_password': [
                'Ingrese su contraseña actual para cambiar la '
                'contraseña.']})
        if not self.instance.check_password(current_password):
            record_event(SecurityEvent.CURRENT_PASSWORD_FAILED,
                         self.context.get('request'), target=self.instance)
            raise serializers.ValidationError({'current_password': [
                'La contraseña actual es incorrecta.']})

    def validate(self, attrs):
        attrs.pop('current_password', None)
        return attrs


class ManageUserSerializer(UserSerializer):
    """Account as the security admin creates, sees and edits it."""

    roles = serializers.SlugRelatedField(
        many=True, slug_field='name', queryset=Role.objects.all(),
        required=False,
        error_messages={'does_not_exist': 'El rol {value} no existe.'})

    class Meta:
        model = get_user_model()
        fields = ['username', 'email', 'nombres',
                  'apellido_paterno', 'apellido_materno', 'name',
                  'is_active', 'roles', 'permissions', 'security_account',
                  'activation_pending', 'is_locked', 'password_expired']

    def to_internal_value(self, data):
        # El administrador nunca escribe contraseñas: una cuenta nueva
        # recibe un enlace de activación (D26) y una existente, uno de
        # restablecimiento (D14, D24). Así nunca las conoce.
        if 'password' in data:
            raise serializers.ValidationError({'password': [
                'El administrador no puede escribir la contraseña de una '
                'cuenta: genere un enlace de restablecimiento.'
                if self.instance is not None else
                'Las cuentas nuevas no reciben una contraseña: su dueño la '
                'elige con el enlace de activación.']})
        internal_value = super().to_internal_value(data)
        # En un formulario, una lista ausente llega vacía: sin el campo
        # roles, la petición no indica roles (no "ningún rol").
        if 'roles' not in data:
            internal_value.pop('roles', None)
        return internal_value

    def validate_roles(self, roles):
        try:
            roles_area(roles)
        except DjangoValidationError as error:
            raise serializers.ValidationError(django_errors(error, 'roles'))
        return roles

    def create(self, validated_data):
        """Create the account with its roles, without a password (D26)."""
        return get_user_model().objects.create_with_roles(**validated_data)

    def update(self, instance, validated_data):
        """Update and return user.

        The roles are checked before saving anything, so a rejected role
        change leaves the account untouched.
        """
        roles = validated_data.pop('roles', None)
        if roles is not None and set(roles) != set(instance.roles.all()):
            if not has_permission(self.context['request'], 'asignar_roles'):
                raise PermissionDenied('No tiene permiso para asignar roles.')
            # Segregación de roles (D18): los roles de seguridad solo se dan
            # al crear la cuenta, y las cuentas que los tienen no se editan
            # aquí (D27), así que tampoco se quitan.
            if roles_area(roles) == SECURITY_AREA:
                raise SecurityRoleSegregation()

        user = super().update(instance, validated_data)

        if roles is not None:
            user.roles.set(roles)

        return user


class AuthTokenSerializer(serializers.Serializer):
    """Serializer for the user auth token."""
    username = serializers.CharField()
    password = serializers.CharField(
        style = {'input_type': 'password'},
        trim_whitespace=False,
    )

    def validate_username(self, value):
        """User IDs are lowercase: accept 'ADM.JPerez' as 'adm.jperez'."""
        return value.lower()

    def validate(self, attrs):
        """Validate and authenticate the user.

        An unknown User ID, a wrong password and an inactive account all
        leave 'user' as None, so the view answers them the same way (D12).
        authenticate() also hashes the password for unknown User IDs, so
        the response time does not reveal which ones exist.
        """
        attrs['user'] = authenticate(
            request=self.context.get('request'),
            username=attrs.get('username'),
            password=attrs.get('password'),
        )
        return attrs


class SecurityEventSerializer(serializers.ModelSerializer):
    """Read-only view of a security event (D28)."""

    event_label = serializers.CharField(source='get_event_type_display',
                                        read_only=True)

    class Meta:
        model = SecurityEvent
        fields = ['id', 'timestamp', 'event_type', 'event_label',
                  'actor_username', 'target_username', 'ip', 'detail']
        read_only_fields = fields


class  SessionSerializer(serializers.ModelSerializer):
    """Serializer for session."""

    class Meta:
        model = Session
        fields = ['id', 'login_time', 'logout_time']
        read_only_fields = ['id', 'login_time', 'logout_time']



class HealthCheckSerializer(serializers.Serializer):
    status = serializers.CharField()


class ResetLinkRequestSerializer(serializers.Serializer):
    """Account the security admin generates a reset link for (D24)."""
    email = serializers.EmailField()


class PasswordLinkSerializer(serializers.Serializer):
    """Token of a password link (D24)."""
    token = serializers.CharField(trim_whitespace=False)


class PasswordLinkUseSerializer(PasswordLinkSerializer):
    """Token of a password link and the new password (D24)."""
    password = serializers.CharField(
        style={'input_type': 'password'}, trim_whitespace=False)


class PermissionSerializer(serializers.ModelSerializer):
    """A permission of the catalog (D15)."""

    class Meta:
        model = Permission
        fields = ['codename', 'name', 'area']
        read_only_fields = fields


class RoleSerializer(serializers.ModelSerializer):
    """A role and its permissions (D15)."""

    permissions = serializers.SlugRelatedField(
        many=True, slug_field='codename', queryset=Permission.objects.all(),
        error_messages={'does_not_exist': 'El permiso {value} no existe.'})
    area = serializers.SerializerMethodField()
    user_count = serializers.SerializerMethodField()

    class Meta:
        model = Role
        fields = ['id', 'name', 'description', 'permissions', 'area',
                  'protected', 'user_count']
        read_only_fields = ['protected']
        # El nombre único se valida en validate_name, con mensaje en español.
        extra_kwargs = {'name': {'validators': []}}

    def get_area(self, obj) -> Optional[str]:
        """Area of the role's permissions: seguridad, laboratorio or
        null if it has none."""
        return obj.area

    def get_user_count(self, obj) -> int:
        return obj.users.count()

    def validate_name(self, value):
        value = value.strip()
        if not value:
            raise serializers.ValidationError('Ingrese el nombre del rol.')
        others = Role.objects.filter(name__iexact=value)
        if self.instance is not None:
            others = others.exclude(pk=self.instance.pk)
        if others.exists():
            raise serializers.ValidationError(
                'Ya existe un rol con ese nombre.')
        return value

    def validate_permissions(self, permissions):
        try:
            area_of(permissions)
        except DjangoValidationError as error:
            raise serializers.ValidationError(
                django_errors(error, 'permissions'))
        return permissions

    def validate(self, attrs):
        """A role with users cannot change area in a way that would give
        security permissions to existing accounts, take them away, or mix
        both areas in one account (D18)."""
        role = self.instance
        if role is None or 'permissions' not in attrs:
            return attrs
        old_area, new_area = role.area, area_of(attrs['permissions'])
        if old_area == new_area or not role.users.exists():
            return attrs
        if SECURITY_AREA in (old_area, new_area):
            raise serializers.ValidationError({'permissions': [
                'El rol tiene usuarios: no puede ganar ni perder permisos de '
                'seguridad, porque los roles de seguridad solo se dan al '
                'crear una cuenta (segregación de roles).']})
        for user in role.users.all():
            try:
                roles_area(user.roles.exclude(pk=role.pk), [new_area])
            except DjangoValidationError:
                raise serializers.ValidationError({'permissions': [
                    f'El usuario {user.username} quedaría con roles de '
                    'seguridad y de laboratorio (segregación de roles).']})
        return attrs
