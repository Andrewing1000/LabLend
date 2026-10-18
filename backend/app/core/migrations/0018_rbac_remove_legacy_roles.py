# Elimina el rol fijo anterior y los permisos y grupos asignados
# directamente al usuario: los permisos salen solo de los roles (D15).

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0017_rbac_copy_roles'),
    ]

    operations = [
        migrations.RemoveField(model_name='user', name='role'),
        migrations.RemoveField(model_name='user', name='groups'),
        migrations.RemoveField(model_name='user', name='user_permissions'),
        migrations.DeleteModel(name='LegacyRole'),
        migrations.AlterModelOptions(name='user', options={}),
        migrations.AlterField(
            model_name='securityevent',
            name='event_type',
            field=models.CharField(choices=[('inicio_sesion', 'Inicio de sesión'), ('inicio_sesion_fallido', 'Inicio de sesión fallido'), ('inicio_sesion_limitado', 'Inicio de sesión rechazado por el límite de intentos'), ('cierre_sesion', 'Cierre de sesión'), ('cuenta_creada', 'Cuenta creada'), ('cuenta_modificada', 'Cuenta modificada por el administrador'), ('perfil_modificado', 'Perfil propio modificado'), ('contrasena_propia_cambiada', 'Contraseña propia cambiada'), ('contrasena_actual_incorrecta', 'Contraseña actual incorrecta al cambiar la contraseña'), ('enlace_restablecimiento_generado', 'Enlace de restablecimiento generado'), ('contrasena_restablecida', 'Contraseña restablecida con un enlace'), ('contrasena_vencida', 'Inicio de sesión con la contraseña vencida'), ('enlace_activacion_generado', 'Enlace de activación generado'), ('cuenta_activada', 'Cuenta activada con un enlace'), ('cuenta_bloqueada', 'Cuenta bloqueada por intentos fallidos'), ('cuenta_desbloqueada', 'Cuenta desbloqueada con un enlace'), ('acceso_denegado', 'Acción rechazada'), ('rol_creado', 'Rol creado'), ('rol_modificado', 'Rol modificado'), ('rol_eliminado', 'Rol eliminado')], db_index=True, max_length=40),
        ),
    ]
