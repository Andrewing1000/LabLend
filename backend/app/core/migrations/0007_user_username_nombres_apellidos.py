"""
D11: los usuarios inician sesión con un código de usuario (User ID)
generado a partir de sus nombres y apellido paterno.

Supone una base de datos sin usuarios (el sistema está en desarrollo):
las cuentas existentes no reciben un código.
"""
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0006_delete_recipe'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='user',
            name='name',
        ),
        migrations.AddField(
            model_name='user',
            name='username',
            field=models.CharField(default='', editable=False,
                                   max_length=150, unique=True),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='user',
            name='nombres',
            field=models.CharField(default='', max_length=255),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='user',
            name='apellido_paterno',
            field=models.CharField(default='', max_length=255),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='user',
            name='apellido_materno',
            field=models.CharField(blank=True, max_length=255),
        ),
    ]
