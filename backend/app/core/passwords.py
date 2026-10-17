"""
Password history (D22)
"""
from django.contrib.auth.hashers import PBKDF2PasswordHasher
from django.core.exceptions import ValidationError
from django_password_validators.password_history.password_validation import (
    UniquePasswordsValidator,
)


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
