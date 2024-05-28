from typing import Any
from django.contrib.sessions.base_session import AbstractBaseSession
from django.contrib.sessions.models import Session, SessionManager
from django.contrib.sessions.backends.db import SessionStore
from django.db import models
from django.contrib.auth import get_user_model


class PersistentSession(AbstractBaseSession):
    user = models.ForeignKey(get_user_model(), null=False, blank=False, on_delete=models.CASCADE)
    start = models.DateTimeField(auto_now_add=True)
    end = models.DateTimeField(null=True, blank=True)


    objects = SessionManager()

    @classmethod
    def get_session_store_class(cls):
        return PerssistentSessionStore

    class Meta(AbstractBaseSession.Meta):
        db_table = 'django_session'



class PerssistentSessionStore(SessionStore):
    @classmethod
    def get_model_class(cls):
        return PersistentSession

    def delete(self, session_key: Any | None = ...) -> None:
        return super().delete(session_key)