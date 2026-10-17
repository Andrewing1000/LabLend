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


from core.models import (Session, SecurityEvent, getAdminRole, getAssistantRole,
                         LAB_ADMIN, LAB_ASSIST, SEC_ADMIN, roleName,
                         username_part)

from rest_framework.exceptions import APIException



class NotValidRole(APIException):
    status_code = 400
    default_detail = 'Ingrese un rol válido'
    default_code = 'role_field'


class SecurityRoleSegregation(APIException):
    status_code = 400
    default_detail = ('El rol de administrador de seguridad no se puede '
                      'asignar ni quitar a una cuenta existente.')
    default_code = 'role_field'
    # Se registra en la bitácora de seguridad como acción rechazada (D28).
    security_event = True


from rest_framework import serializers
from django.contrib.auth import get_user_model

from typing import Optional
from rest_framework import serializers
from django.contrib.auth import get_user_model

class UserSerializer(serializers.ModelSerializer):
    """Serializer for the user object."""

    role_field = serializers.SerializerMethodField()
    name = serializers.ReadOnlyField()

    class Meta:
        model = get_user_model()
        fields = ['username', 'email', 'password', 'nombres',
                  'apellido_paterno', 'apellido_materno', 'name',
                  'is_active', 'role_field']
        extra_kwargs = {
            'password': {'write_only': True, 'min_length': 12},
            'email': {'required':False},
            'role_field': {'read_only': True},
            'is_active': {'read_only': True},
        }

    def get_role_field(self, obj) -> Optional[str]:
        """Get the role name of the user."""
        return roleName(obj)

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

class ManageUserSerializer(UserSerializer):

    role_field = serializers.SerializerMethodField()

    class Meta:
        model = get_user_model()
        fields = ['username', 'email', 'password', 'nombres',
                  'apellido_paterno', 'apellido_materno', 'name',
                  'is_active', 'role_field']
        extra_kwargs = {'password':{'write_only': True, 'min_length': 12},
                        'role_field': {'read_only': False},}

    def to_internal_value(self, data):
        # data puede ser un QueryDict inmutable (formularios): solo leerlo.
        external_field_value = data.get('role_field', None)
        internal_value = super().to_internal_value(data)
        internal_value['role_field'] = external_field_value
        return internal_value


    def create(self, validated_data):
        """Create and return a user with encrypted password"""
        role_name = validated_data.pop('role_field', None)
        user = get_user_model().objects.create_user(**validated_data)

        if role_name:
            if(role_name == LAB_ASSIST):
                user.role = getAssistantRole()
            elif(role_name == LAB_ADMIN):
                user.role = getAdminRole()
            else:
                raise NotValidRole()

        user.save()

        return user


    def update(self, instance, validated_data):
        """Update and return user.

        The role is checked before saving anything, so a rejected role
        change leaves the account untouched.
        """
        role_name = validated_data.pop('role_field', None)
        new_role = None
        if role_name and role_name != roleName(instance):
            # Segregación de roles (D18): el rol de administrador de
            # seguridad no se asigna ni se quita a una cuenta existente.
            if SEC_ADMIN in (role_name, roleName(instance)):
                raise SecurityRoleSegregation()
            if(role_name == LAB_ASSIST):
                new_role = getAssistantRole()
            elif(role_name == LAB_ADMIN):
                new_role = getAdminRole()
            else:
                raise NotValidRole()

        user = super().update(instance, validated_data)

        if new_role:
            user.role = new_role
            user.save()

        return user

class AssistanSerializer(ManageUserSerializer):

    def create(self, validated_data):
        """Create and return a user with encrypted password"""
        validated_data.pop('role_field')
        return get_user_model().objects.create_lab_assistant(**validated_data)


class AdminSerializer(ManageUserSerializer):

    def create(self, validated_data):
        """Create and return a user with encrypted password"""
        validated_data.pop('role_field')
        return get_user_model().objects.create_lab_admin(**validated_data)




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
