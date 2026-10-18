# Roles en la base de datos con permisos por función (D15). Primera de tres
# migraciones: crea las tablas nuevas junto a las anteriores; 0017 copia los
# roles de los usuarios y 0018 elimina el modelo anterior.

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0015_securityevent_password_expired'),
    ]

    operations = [
        migrations.DeleteModel(name='LabAdmin'),
        migrations.DeleteModel(name='LabAssistant'),
        migrations.DeleteModel(name='SecurityAdmin'),
        migrations.RenameModel(old_name='Role', new_name='LegacyRole'),
        migrations.CreateModel(
            name='Permission',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('codename', models.CharField(max_length=50, unique=True)),
                ('name', models.CharField(max_length=255)),
                ('area', models.CharField(choices=[('seguridad', 'Seguridad'), ('laboratorio', 'Laboratorio')], max_length=20)),
            ],
            options={
                'ordering': ['area', 'codename'],
            },
        ),
        migrations.CreateModel(
            name='Role',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100, unique=True)),
                ('description', models.CharField(blank=True, max_length=255)),
                ('protected', models.BooleanField(default=False, editable=False)),
                ('permissions', models.ManyToManyField(blank=True, related_name='roles', to='core.permission')),
            ],
            options={
                'ordering': ['name'],
            },
        ),
        migrations.AddField(
            model_name='user',
            name='roles',
            field=models.ManyToManyField(blank=True, related_name='users', to='core.role'),
        ),
    ]
