"""
Password history (D22) and password links (D24)
"""
import hashlib
import secrets
from datetime import timedelta
from urllib.parse import urlencode

from django.conf import settings
from django.contrib.auth.hashers import PBKDF2PasswordHasher
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.db import transaction
from django.utils import timezone
from django_password_validators.password_history.password_validation import (
    UniquePasswordsValidator,
)

from core.models import PasswordLink, logOut


class PasswordHistoryHasher(PBKDF2PasswordHasher):
    """Hasher for the password history (DPV_DEFAULT_HISTORY_HASHER).

    The history package compares hashes by equality, with a fixed salt per
    user and the iterations stored with it, so it needs a PBKDF2 hasher
    (Argon2 has no iterations to store). The iterations are fixed here
    instead of inherited, so a Django upgrade does not change them:
    1 000 000, Django's value for passwords, above OWASP's 600 000.
    """
    iterations = 1_000_000


class PasswordHistoryValidator(UniquePasswordsValidator):
    """Reject the current password and the previous ones in the history.

    The history includes the current password, so last_passwords=5 is the
    current password and the 4 before it. The package's Spanish message
    says any past password is rejected, which is not true, so it is
    replaced.
    """

    def validate(self, password, user=None):
        try:
            super().validate(password, user)
        except ValidationError as error:
            raise ValidationError(
                'La contraseña no puede ser igual a la actual ni a las '
                f'{self.last_passwords - 1} anteriores.',
                code=error.code,
            )

    def get_help_text(self):
        return (
            'La contraseña no puede ser igual a la actual ni a las '
            f'{self.last_passwords - 1} anteriores.'
        )


def hash_token(token):
    return hashlib.sha256(token.encode()).hexdigest()


def link_url(token):
    """Address of the web app page that opens the link."""
    return f'{settings.FRONTEND_URL}/?{urlencode({"enlace": token})}'


@transaction.atomic
def create_password_link(user, created_by):
    """Create a password link for user and return (link, token).

    An account that has never had a password gets an activation link
    (D26). Any other account gets a reset link (D24): its current
    password stops working at once, in case the account was compromised;
    that also closes its open sessions, because Django checks a hash of
    the password on every request. Earlier links that were not used stop
    working too. The token is returned only here: the database keeps its
    hash.
    """
    if user.activation_pending:
        purpose = PasswordLink.ACTIVATION
    else:
        purpose = PasswordLink.RESET
        user.set_unusable_password()
        user.save(update_fields=['password'])
        logOut(user)

    PasswordLink.objects.filter(user=user, used_at__isnull=True).delete()
    token = secrets.token_urlsafe(32)
    link = PasswordLink.objects.create(
        user=user,
        purpose=purpose,
        token_hash=hash_token(token),
        created_by=created_by,
        expires_at=timezone.now() + timedelta(
            hours=settings.PASSWORD_LINK_HOURS),
    )
    return link, token


def find_valid_link(token):
    """The unused, unexpired link for token, or None."""
    if not token:
        return None
    link = PasswordLink.objects.select_related('user').filter(
        token_hash=hash_token(str(token))).first()
    if link is None or not link.is_valid() or not link.user.is_active:
        return None
    return link


@transaction.atomic
def use_link(token, password):
    """Set password with the link of token and close the link.

    Returns the used link, or None if it is not valid. Raises
    ValidationError if the password does not satisfy the policy,
    history included; the link then stays usable.
    """
    link = find_valid_link(token)
    if link is None:
        return None
    # Bloquea la fila: dos envíos simultáneos no pueden usar el mismo enlace.
    link = PasswordLink.objects.select_for_update().get(pk=link.pk)
    if not link.is_valid():
        return None

    user = link.user
    validate_password(password, user=user)
    user.set_password(password)
    user.save()
    link.used_at = timezone.now()
    link.save(update_fields=['used_at'])
    return link
