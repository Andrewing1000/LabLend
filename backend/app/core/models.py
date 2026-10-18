"""
Database models
"""
import unicodedata
from datetime import timedelta

from django.conf import settings
from django.db import models
from django.contrib.auth import get_user_model
from django.contrib.auth.models import (
    AbstractBaseUser,
    BaseUserManager,
)

from core.rbac import (AREAS, LAB_ADMIN, LAB_ASSIST, SEC_ADMIN,
                       SECURITY_AREA, create_default_role)

from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import PermissionDenied, ValidationError

from django.utils import timezone


class Permission(models.Model):
    """One function of the system that a role can allow (D15). The
    catalog is in core.rbac and every view declares the one it requires
    (D16)."""

    codename = models.CharField(max_length=50, unique=True)
    name = models.CharField(max_length=255)
    area = models.CharField(max_length=20, choices=AREAS)

    class Meta:
        ordering = ['area', 'codename']

    def __str__(self):
        return self.codename


def area_of(permissions):
    """Area of a set of permissions, None if it is empty. A role cannot
    mix security and lab permissions (D18)."""
    areas = {permission.area for permission in permissions}
    if len(areas) > 1:
        raise ValidationError({'permissions': [
            'Un rol no puede combinar permisos de seguridad y de '
            'laboratorio (segregación de roles).']})
    return areas.pop() if areas else None


class Role(models.Model):
    """Role stored in the database, with permissions per function (D15).
    A user can have several roles."""

    name = models.CharField(max_length=100, unique=True)
    description = models.CharField(max_length=255, blank=True)
    permissions = models.ManyToManyField(Permission, blank=True,
                                         related_name='roles')
    # El rol de administrador de seguridad (D27): no se modifica ni se
    # elimina, y siempre tiene todos los permisos de seguridad.
    protected = models.BooleanField(default=False, editable=False)

    class Meta:
        ordering = ['name']

    @property
    def area(self):
        return area_of(self.permissions.all())

    def __str__(self):
        return self.name


def roles_area(roles, extra_areas=()):
    """Area of the roles a user holds, None if none has permissions.
    Nobody can hold security and lab roles at the same time (D18)."""
    areas = {role.area for role in roles} | set(extra_areas)
    areas.discard(None)
    if len(areas) > 1:
        raise ValidationError({'roles': [
            'Un usuario no puede tener a la vez roles de seguridad y de '
            'laboratorio (segregación de roles).']})
    return areas.pop() if areas else None


def default_role(name):
    """A default role (core.rbac.DEFAULT_ROLES), created if missing."""
    return create_default_role(Role, Permission, name)


def roleNames(user):
    """Names of the roles of the user, sorted."""
    if not getattr(user, 'pk', None):
        return []
    return sorted(user.roles.values_list('name', flat=True))


def roleName(user):
    """One role name of the user, or None if it has no role. Kept for the
    app until its menu uses the permissions (D17)."""
    names = roleNames(user)
    return names[0] if names else None


def isSecurityAdmin(user):
    """Holds the protected security admin role (D27)."""
    return bool(getattr(user, 'pk', None)) and user.roles.filter(
        protected=True).exists()


def isSecurityAccount(user):
    """Holds a role with security permissions. These accounts get that
    role when they are created, and are not modified from the account
    management (D18, D27)."""
    return bool(getattr(user, 'pk', None)) and user.roles.filter(
        permissions__area=SECURITY_AREA).exists()


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
        if password is None:
            # Cuenta nueva desde la aplicación (D26): sin contraseña hasta
            # que su dueño la elija con el enlace de activación.
            user.set_unusable_password()
        else:
            validate_password(password)
            user.set_password(password)
        user.save(using=self._db)

        return user

    def create_with_roles(self, email, password=None, roles=(),
                          **extra_fields):
        """Create a user with its roles. Accounts with a security role
        get the adm. prefix in their User ID."""
        roles = list(roles)
        if roles_area(roles) == SECURITY_AREA:
            extra_fields['username_prefix'] = ADMIN_USERNAME_PREFIX
        user = self.create_user(email, password, **extra_fields)
        user.roles.set(roles)
        return user

    def create_lab_admin(self, email, password=None, **extra_fields):
        return self.create_with_roles(
            email, password, [default_role(LAB_ADMIN)], **extra_fields)

    def create_lab_assistant(self, email, password=None, **extra_fields):
        return self.create_with_roles(
            email, password, [default_role(LAB_ASSIST)], **extra_fields)

    def create_security_admin(self, email, password=None, **extra_fields):
        """Security admins always get the adm. prefix in their User ID."""
        extra_fields.pop('username_prefix', None)
        return self.create_with_roles(
            email, password, [default_role(SEC_ADMIN)], **extra_fields)

    # Sin create_superuser (D27): ninguna cuenta queda fuera de los roles.
    # La cuenta inicial se crea con create_initial_admin.


class User(AbstractBaseUser):
    """User in the system. Its permissions come only from its roles
    (D15): there are no permissions or groups assigned to the user
    directly."""

    username = models.CharField(max_length=150, unique=True, editable=False)
    email = models.EmailField(max_length=255, unique=True)
    nombres = models.CharField(max_length=255)
    apellido_paterno = models.CharField(max_length=255)
    apellido_materno = models.CharField(max_length=255, blank=True)
    is_active = models.BooleanField(default=True)
    # Cuándo eligió el usuario su contraseña actual. Vacío mientras la cuenta
    # espera su activación (D26); el vencimiento a los 90 días (D21) se
    # cuenta desde aquí.
    password_changed_at = models.DateTimeField(null=True, blank=True)
    # Bloqueo por intentos fallidos (D23): inicios de sesión fallidos
    # seguidos, y cuándo se bloqueó la cuenta (vacío si no lo está).
    failed_login_attempts = models.PositiveSmallIntegerField(default=0)
    locked_at = models.DateTimeField(null=True, blank=True)
    roles = models.ManyToManyField(Role, blank=True, related_name='users')

    objects = UserManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email', 'nombres', 'apellido_paterno']

    # D27: sin superusuarios. Siempre es False, por si algún código de
    # Django lo consulta.
    @property
    def is_superuser(self):
        return False

    def get_permissions(self):
        """Codenames of the permissions of all the user's roles."""
        if not self.pk or not self.is_active:
            return set()
        return set(Permission.objects.filter(roles__users=self)
                   .values_list('codename', flat=True))

    def has_perm(self, perm, obj=None):
        """The user may use the function: one of its roles allows it."""
        return perm in self.get_permissions()

    def save(self, *args, **kwargs):
        """Never leave the system without an active security admin (D27),
        not even from the server shell."""
        if (self.pk and not self.is_active and isSecurityAdmin(self)
                and not User.objects.filter(
                    roles__protected=True, is_active=True,
                ).exclude(pk=self.pk).exists()):
            raise ValidationError(
                'No se puede desactivar al último administrador de '
                'seguridad activo.')
        super().save(*args, **kwargs)

    def set_password(self, raw_password):
        """Choosing a new password also unlocks the account (D23): it is
        only possible with a reset link, from an open session or with
        changepassword on the server."""
        super().set_password(raw_password)
        self.password_changed_at = timezone.now()
        self.failed_login_attempts = 0
        self.locked_at = None

    @property
    def password_expired(self):
        """The password was chosen more than PASSWORD_MAX_AGE_DAYS ago
        (D21). An account pending activation has no password to expire."""
        if self.password_changed_at is None:
            return False
        max_age = timedelta(days=settings.PASSWORD_MAX_AGE_DAYS)
        return timezone.now() - self.password_changed_at > max_age

    @property
    def is_locked(self):
        """Locked after too many failed logins in a row (D23)."""
        return self.locked_at is not None

    @property
    def activation_pending(self):
        """The account was created but its owner has not chosen a
        password yet (D26)."""
        return self.password_changed_at is None

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
    CURRENT_PASSWORD_FAILED = 'contrasena_actual_incorrecta'
    RESET_LINK_CREATED = 'enlace_restablecimiento_generado'
    PASSWORD_RESET = 'contrasena_restablecida'
    PASSWORD_EXPIRED = 'contrasena_vencida'
    ACTIVATION_LINK_CREATED = 'enlace_activacion_generado'
    ACCOUNT_ACTIVATED = 'cuenta_activada'
    ACCOUNT_LOCKED = 'cuenta_bloqueada'
    ACCOUNT_UNLOCKED = 'cuenta_desbloqueada'
    ACCESS_DENIED = 'acceso_denegado'
    ROLE_CREATED = 'rol_creado'
    ROLE_UPDATED = 'rol_modificado'
    ROLE_DELETED = 'rol_eliminado'

    EVENT_TYPES = [
        (LOGIN, 'Inicio de sesión'),
        (LOGIN_FAILED, 'Inicio de sesión fallido'),
        (LOGIN_THROTTLED, 'Inicio de sesión rechazado por el límite de intentos'),
        (LOGOUT, 'Cierre de sesión'),
        (ACCOUNT_CREATED, 'Cuenta creada'),
        (ACCOUNT_UPDATED, 'Cuenta modificada por el administrador'),
        (PROFILE_UPDATED, 'Perfil propio modificado'),
        (OWN_PASSWORD_CHANGED, 'Contraseña propia cambiada'),
        (CURRENT_PASSWORD_FAILED,
         'Contraseña actual incorrecta al cambiar la contraseña'),
        (RESET_LINK_CREATED, 'Enlace de restablecimiento generado'),
        (PASSWORD_RESET, 'Contraseña restablecida con un enlace'),
        (PASSWORD_EXPIRED, 'Inicio de sesión con la contraseña vencida'),
        (ACTIVATION_LINK_CREATED, 'Enlace de activación generado'),
        (ACCOUNT_ACTIVATED, 'Cuenta activada con un enlace'),
        (ACCOUNT_LOCKED, 'Cuenta bloqueada por intentos fallidos'),
        (ACCOUNT_UNLOCKED, 'Cuenta desbloqueada con un enlace'),
        (ACCESS_DENIED, 'Acción rechazada'),
        (ROLE_CREATED, 'Rol creado'),
        (ROLE_UPDATED, 'Rol modificado'),
        (ROLE_DELETED, 'Rol eliminado'),
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


class PasswordLink(models.Model):
    """Single-use link to choose a new password (D24).

    Only the SHA-256 hash of the token is stored: whoever reads the
    database cannot use a pending link.
    """

    RESET = 'restablecimiento'
    ACTIVATION = 'activacion'
    PURPOSES = [
        (RESET, 'Restablecimiento de contraseña'),
        (ACTIVATION, 'Activación de cuenta'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE,
                             related_name='password_links')
    purpose = models.CharField(max_length=20, choices=PURPOSES)
    token_hash = models.CharField(max_length=64, unique=True)
    created_by = models.ForeignKey(User, null=True, blank=True,
                                   on_delete=models.SET_NULL, related_name='+')
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    used_at = models.DateTimeField(null=True, blank=True)

    def is_valid(self):
        return self.used_at is None and timezone.now() < self.expires_at


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




