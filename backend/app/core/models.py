"""
Database models
"""
from django.conf import settings
from django.db import models
from django.contrib.auth import get_user_model
from django.contrib.auth.models import (
    AbstractBaseUser,
    BaseUserManager,
)

from core.permissions import Role, RolePermissionsMixin

from django.contrib.auth.password_validation import validate_password

from django.utils import timezone

from rest_framework.permissions import BasePermission

LAB_ADMIN = 'AdministradorLaboratorio'
LAB_ASSIST = 'AsistenteLaboratorio'


class IsLabAdmin(BasePermission):

    def has_permission(self, request, view):
        user = request.user
        role = user.role

        if(user.is_superuser):
            return True
        if(role.role_name == LAB_ADMIN):
            return True
        return False

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
        print(LAB_ASSIST + "LabAssistant  Added")
    except:
        LabAssistant.objects.create()
        print(LAB_ASSIST + "LabAssistant Added")

def createRoles():
    createAdminRole()
    createAssistantRole()


def createSuperInstance():
    data = {
            'email' : 'admin@example.com',
            'password' : '#123#AndresHinojosa#123',
    }

    admin = get_user_model().objects.filter(email = data['email']).first()
    if admin:
        print("Admin instance already created")
        return

    get_user_model().objects.create_superuser(**data)
    print("Admin instance created")

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
        return LabAssistant.objects.get(role_name = LAB_ASSIST)


class UserManager(BaseUserManager):
    """Manager for users."""

    def create_user(self, email, password=None, **extra_fields):
        """Create, save and return a new user."""
        if not email:
            raise ValueError('User must have an email address')
        user = self.model(email=self.normalize_email(email), **extra_fields)
        validate_password(password)
        user.set_password(password)
        user.save(using=self._db)

        return user

    def create_lab_admin(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('User must have an email address')
        user = self.model(email=self.normalize_email(email), **extra_fields)
        user.role = getAdminRole()
        validate_password(password)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_lab_assistant(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('User must have an email address')
        user = self.model(email=self.normalize_email(email), **extra_fields)
        user.role = getAssistantRole()
        validate_password(password)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password):
        """Create and return a new superuser."""
        user = self.create_user(email, password)
        user.is_staff = True
        user.is_superuser = True
        user.save(using=self._db)

        return user


class User(AbstractBaseUser, RolePermissionsMixin):
    """User in the system."""

    class Meta:
        permissions = [("own_password_modification", "Modification of self's account password"),
                       ("own_phone_modification", "Modification of self's account phone number"),]

    email = models.EmailField(max_length=255, unique=True)
    name = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'email'





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

        user = request.user
        return isLogged(user) or user.is_superuser


