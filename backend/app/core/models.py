"""
Database models
"""
import unicodedata

from django.conf import settings
from django.db import models
from django.contrib.auth import get_user_model
from django.contrib.auth.models import (
    AbstractBaseUser,
    BaseUserManager,
)

from core.permissions import Role, RolePermissionsMixin

from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import PermissionDenied, ValidationError

from django.utils import timezone

from rest_framework.permissions import BasePermission

LAB_ADMIN = 'AdministradorLaboratorio'
LAB_ASSIST = 'AsistenteLaboratorio'
SEC_ADMIN = 'AdministradorSeguridad'


def roleName(user):
    """Role name of the user, or None if it has no role."""
    role = getattr(user, 'role', None)
    return role.role_name if role else None


# Sin excepciones para superusuarios (D27): todo permiso sale del rol.

def isAdmin(user):
    """Lab admin: manages inventory and sees every loan."""
    return roleName(user) == LAB_ADMIN


def isSecurityAdmin(user):
    """Security admin: manages user accounts only (D18)."""
    return roleName(user) == SEC_ADMIN


def isLabStaff(user):
    """Lab admin or assistant: the roles that work with loans."""
    return roleName(user) in (LAB_ADMIN, LAB_ASSIST)



class IsLabAdmin(BasePermission):

    def has_permission(self, request, view):
        return isAdmin(request.user)


class IsSecurityAdmin(BasePermission):

    def has_permission(self, request, view):
        return isSecurityAdmin(request.user)


class IsLabStaff(BasePermission):

    def has_permission(self, request, view):
        return isLabStaff(request.user)

class LabAdmin(Role):
    """Lab Administrator role"""

    class Meta:
        permissions = [ ("lab_admin_creation", "Creation of lab admin users"),
                        ("lab_admin_modification", "Modification of lab admin users"),
                        ("assistant_inactivation", "Deletion of assistant users"),
                        ("assistant_modification", "Modification of assistant users"),
                        ("assistant_creation", "Creation of assistan users"),
                        ]
        proxy = True

    def save(self, *args, **kwargs):
        self.role_name = LAB_ADMIN
        super().save(*args, **kwargs)


class LabAssistant(Role):
    """Lab Assistant role"""

    class Meta:
        permissions = []
        proxy = True

    def save(self, *args, **kwargs):
        self.role_name = LAB_ASSIST
        super().save(*args, **kwargs)


class SecurityAdmin(Role):
    """Security Administrator role: manages user accounts, separated
    from the lab administrator (D18)"""

    class Meta:
        permissions = []
        proxy = True

    def save(self, *args, **kwargs):
        self.role_name = SEC_ADMIN
        super().save(*args, **kwargs)


def createAdminRole():
    try:
        Role.objects.get(role_name = LAB_ADMIN)
        print(LAB_ADMIN + "LabAdmin Already Added")
    except:
        LabAdmin.objects.create()
        print(LAB_ADMIN + "LabAdmin Added")

def createAssistantRole():
    try:
        Role.objects.get(role_name = LAB_ASSIST)
        print(LAB_ASSIST + "LabAssistant Already Added")
    except:
        LabAssistant.objects.create()
        print(LAB_ASSIST + "LabAssistant Added")

def createSecurityAdminRole():
    try:
        Role.objects.get(role_name = SEC_ADMIN)
        print(SEC_ADMIN + "SecurityAdmin Already Added")
    except:
        SecurityAdmin.objects.create()
        print(SEC_ADMIN + "SecurityAdmin Added")

def createRoles():
    createAdminRole()
    createAssistantRole()
    createSecurityAdminRole()


def getAdminRole():
    try:
        return LabAdmin.objects.get(role_name = LAB_ADMIN)
    except:
        createAdminRole()
        return LabAdmin.objects.get(role_name = LAB_ADMIN)


def getAssistantRole():
    try:
        return LabAssistant.objects.get(role_name = LAB_ASSIST)
    except:
        createAssistantRole()
        return LabAssistant.objects.get(role_name = LAB_ASSIST)


def getSecurityAdminRole():
    try:
        return SecurityAdmin.objects.get(role_name = SEC_ADMIN)
    except:
        createSecurityAdminRole()
        return SecurityAdmin.objects.get(role_name = SEC_ADMIN)


ADMIN_USERNAME_PREFIX = 'adm'
USER_USERNAME_PREFIX = 'usr'


def username_part(value):
    """Lowercase ASCII letters of a name: 'De la Peña' -> 'delapena'."""
    decomposed = unicodedata.normalize('NFKD', value or '')
    return ''.join(c for c in decomposed.lower() if 'a' <= c <= 'z')


class UserManager(BaseUserManager):
    """Manager for users."""

    def generate_username(self, prefix, nombres, apellido_paterno):
        """Build the User ID: prefix.initial+surname, with a number if taken."""
        initial = username_part(nombres)[:1]
        surname = username_part(apellido_paterno)
        if not initial or not surname:
            raise ValueError('User must have nombres and apellido_paterno')
        base = f'{prefix}.{initial}{surname}'
        username = base
        suffix = 2
        while self.filter(username=username).exists():
            username = f'{base}{suffix}'
            suffix += 1
        return username

    def create_user(self, email, password=None,
                    username_prefix=USER_USERNAME_PREFIX, **extra_fields):
        """Create, save and return a new user with a generated User ID."""
        if not email:
            raise ValueError('User must have an email address')
        extra_fields.pop('username', None)
        user = self.model(email=self.normalize_email(email), **extra_fields)
        user.username = self.generate_username(
            username_prefix, user.nombres, user.apellido_paterno)
        validate_password(password)
        user.set_password(password)
        user.save(using=self._db)

        return user

    def create_lab_admin(self, email, password=None, **extra_fields):
        user = self.create_user(email, password, **extra_fields)
        user.role = getAdminRole()
        user.save(using=self._db)
        return user

    def create_lab_assistant(self, email, password=None, **extra_fields):
        user = self.create_user(email, password, **extra_fields)
        user.role = getAssistantRole()
        user.save(using=self._db)
        return user

    def create_security_admin(self, email, password=None, **extra_fields):
        """Security admins always get the adm. prefix in their User ID."""
        extra_fields.pop('username_prefix', None)
        user = self.create_user(email, password,
                                username_prefix=ADMIN_USERNAME_PREFIX,
                                **extra_fields)
        user.role = getSecurityAdminRole()
        user.save(using=self._db)
        return user

    # Sin create_superuser (D27): ninguna cuenta queda fuera de los roles.
    # La cuenta inicial se crea con create_initial_admin.


class User(AbstractBaseUser, RolePermissionsMixin):
    """User in the system."""

    class Meta:
        permissions = [("own_password_modification", "Modification of self's account password"),
                       ("own_phone_modification", "Modification of self's account phone number"),]

    username = models.CharField(max_length=150, unique=True, editable=False)
    email = models.EmailField(max_length=255, unique=True)
    nombres = models.CharField(max_length=255)
    apellido_paterno = models.CharField(max_length=255)
    apellido_materno = models.CharField(max_length=255, blank=True)
    is_active = models.BooleanField(default=True)

    objects = UserManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email', 'nombres', 'apellido_paterno']

    # D27: sin superusuarios. Reemplaza el campo is_superuser de
    # PermissionsMixin; Django lo sigue consultando, así que siempre es False.
    @property
    def is_superuser(self):
        return False

    def save(self, *args, **kwargs):
        """Never leave the system without an active security admin (D27),
        not even from the server shell."""
        if (self.pk and not self.is_active and roleName(self) == SEC_ADMIN
                and not User.objects.filter(
                    role__role_name=SEC_ADMIN, is_active=True,
                ).exclude(pk=self.pk).exists()):
            raise ValidationError(
                'No se puede desactivar al último administrador de '
                'seguridad activo.')
        super().save(*args, **kwargs)

    @property
    def name(self):
        """Full name, for display."""
        return ' '.join(part for part in (
            self.nombres, self.apellido_paterno, self.apellido_materno)
            if part)

    def __str__(self):
        return self.username





class SecurityEventQuerySet(models.QuerySet):
    """Bulk update() and delete() skip the model's save() and delete():
    block them too."""

    def update(self, **kwargs):
        raise PermissionDenied(
            'Los eventos de seguridad no se pueden modificar.')

    def delete(self):
        raise PermissionDenied(
            'Los eventos de seguridad no se pueden eliminar.')


class SecurityEvent(models.Model):
    """Security event log (D28). Rows are only ever added: they cannot be
    edited or deleted, so whoever acts cannot erase the trace."""

    objects = SecurityEventQuerySet.as_manager()

    LOGIN = 'inicio_sesion'
    LOGIN_FAILED = 'inicio_sesion_fallido'
    LOGIN_THROTTLED = 'inicio_sesion_limitado'
    LOGOUT = 'cierre_sesion'
    ACCOUNT_CREATED = 'cuenta_creada'
    ACCOUNT_UPDATED = 'cuenta_modificada'
    PROFILE_UPDATED = 'perfil_modificado'
    OWN_PASSWORD_CHANGED = 'contrasena_propia_cambiada'
    ACCESS_DENIED = 'acceso_denegado'

    EVENT_TYPES = [
        (LOGIN, 'Inicio de sesión'),
        (LOGIN_FAILED, 'Inicio de sesión fallido'),
        (LOGIN_THROTTLED, 'Inicio de sesión rechazado por el límite de intentos'),
        (LOGOUT, 'Cierre de sesión'),
        (ACCOUNT_CREATED, 'Cuenta creada'),
        (ACCOUNT_UPDATED, 'Cuenta modificada por el administrador'),
        (PROFILE_UPDATED, 'Perfil propio modificado'),
        (OWN_PASSWORD_CHANGED, 'Contraseña propia cambiada'),
        (ACCESS_DENIED, 'Acción rechazada'),
    ]

    timestamp = models.DateTimeField(auto_now_add=True, db_index=True)
    event_type = models.CharField(max_length=40, choices=EVENT_TYPES,
                                  db_index=True)
    # Quién actuó y sobre qué cuenta. Se guarda también el código de usuario
    # como texto, para que el registro se lea igual aunque la cuenta cambie.
    actor = models.ForeignKey(User, null=True, blank=True,
                              on_delete=models.SET_NULL, related_name='+')
    actor_username = models.CharField(max_length=150, blank=True)
    target = models.ForeignKey(User, null=True, blank=True,
                               on_delete=models.SET_NULL, related_name='+')
    target_username = models.CharField(max_length=150, blank=True)
    ip = models.GenericIPAddressField(null=True, blank=True)
    # Detalle del evento: campos cambiados, rol, ruta rechazada... Nunca
    # contiene contraseñas.
    detail = models.JSONField(default=dict, blank=True)

    class Meta:
        ordering = ['-timestamp', '-id']

    def save(self, *args, **kwargs):
        if self.pk is not None:
            raise PermissionDenied(
                'Los eventos de seguridad no se pueden modificar.')
        super().save(*args, **kwargs)

    def delete(self, *args, **kwargs):
        raise PermissionDenied(
            'Los eventos de seguridad no se pueden eliminar.')


class Session(models.Model):
    user = models.ForeignKey(get_user_model(), null=False, blank=False, on_delete=models.CASCADE)
    login_time = models.DateTimeField(auto_now_add=True)
    logout_time =  models.DateTimeField(null=True, blank=True)
    #session_key = models.CharField(max_length=255,  null=False, blank=True)


def get_last_session(user):

    if not user.is_authenticated:
        return None

    last_session = Session.objects.filter(user=user).order_by('-login_time').first()
    if last_session:
        return last_session
    else:
        return None

def get_open_session(user):

    last_session = get_last_session(user)

    if not last_session: return None

    if last_session.logout_time:
        return None
    else:
        return last_session

def isLogged(user):
    if get_open_session(user):
        return True
    return False

def logOut(user):
    last_session = get_open_session(user)
    if not last_session:
        return

    last_session.logout_time = timezone.now()
    last_session.save()

def logIn(user):

    if not user.is_authenticated:
        return
    if get_open_session(user):
        logOut(user)
    Session.objects.create(user=user)



class IsLogged(BasePermission):

    def has_permission(self, request, view):

        return isLogged(request.user)


