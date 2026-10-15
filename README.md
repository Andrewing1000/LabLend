# LabLend

Sistema de inventario y préstamo de equipos de laboratorio: una API REST en Django con base de datos PostgreSQL y una aplicación Flutter para web, móvil y escritorio.

| Carpeta | Contenido |
| --- | --- |
| `backend/` | API REST (Python 3.12, Django 5.2 LTS, PostgreSQL 17), ejecutada con Docker |
| `frontend/` | Aplicación Flutter |
| `docs/` | Documento del proyecto de Ética y Seguridad de Sistemas |

## Requisitos

| Herramienta | Para qué | Versión probada |
| --- | --- | --- |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) con Docker Compose v2 | Ejecutar la API y la base de datos | Docker 29, Compose 5 |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal stable) | Ejecutar la aplicación | Flutter 3.47, Dart 3.13 |
| Google Chrome o Microsoft Edge | Versión web de la aplicación | — |
| Android Studio con un emulador (opcional) | Versión Android de la aplicación | — |

No hace falta instalar Python ni PostgreSQL: ambos corren dentro de Docker.

## 1. Levantar el backend

Desde la raíz del repositorio, con Docker Desktop abierto:

```bash
docker compose -f backend/docker-compose.yml up --build
```

La primera vez construye la imagen, espera a la base de datos, aplica las migraciones y crea los roles iniciales. Queda disponible en:

- API: http://localhost:8000
- Documentación de la API (Swagger): http://localhost:8000/api/docs/
- Verificación de estado: http://localhost:8000/health_check

Para detenerlo, `Ctrl+C` en esa terminal, o desde otra terminal:

```bash
docker compose -f backend/docker-compose.yml down
```

Para detenerlo y además borrar la base de datos:

```bash
docker compose -f backend/docker-compose.yml down -v
```

### Crear la cuenta inicial

El sistema no trae cuentas predefinidas: las migraciones solo crean los roles, así que la base de datos empieza sin usuarios. Con el backend levantado, crea el primer administrador:

```bash
docker compose -f backend/docker-compose.yml run --rm app_new python manage.py create_initial_admin --email admin@lablend.test --name "Administrador"
```

- **Correo y nombre:** los que pases al comando.
- **Contraseña:** el comando la genera al azar, cumpliendo la política de contraseñas, y la muestra **una sola vez** en la terminal. Guárdala de inmediato en el gestor de contraseñas: la base de datos solo guarda su hash, así que no hay forma de volver a verla. Nadie la conoce de antemano y no está en el código ni en git.
- **Rol:** administrador de laboratorio. Cuando exista el rol de administrador de seguridad (D18), la cuenta inicial tendrá ese rol.
- **Solo una vez:** el comando se niega a ejecutarse si ya existe un administrador. Las demás cuentas, administradores y asistentes, se crean desde la aplicación con esa cuenta.

Si se pierde la contraseña del administrador, cámbiala desde el servidor; el comando pide la nueva contraseña y aplica la misma política:

```bash
docker compose -f backend/docker-compose.yml run --rm app_new python manage.py changepassword admin@lablend.test
```

> Si tu base de datos es anterior a este cambio, todavía tiene la cuenta `admin@example.com`, cuya contraseña está publicada en el historial de git. Desactívala, o empieza con una base vacía con `down -v` (borra también los datos locales).

> Si ya tenías el backend con la versión anterior (PostgreSQL 13), la base de datos empieza vacía después de actualizar: Django 5.2 requiere PostgreSQL 14 o superior y los datos anteriores no se migran.

## 2. Ejecutar la aplicación Flutter (web)

Con el backend corriendo, en otra terminal:

```bash
cd frontend
```

```bash
flutter pub get
```

```bash
flutter run -d chrome --web-port 58315
```

Para usar Edge, cambia `-d chrome` por `-d edge`.

**Usa el puerto 58315 (o 65420).** Django solo acepta peticiones desde los orígenes listados en `CORS_ALLOWED_ORIGINS` y `CSRF_TRUSTED_ORIGINS` (`backend/app/app/settings.py`). Con otro puerto el navegador bloquea las peticiones a la API (error CORS en la consola) y la aplicación no puede cargar datos.

Teclas útiles mientras corre: `r` recarga el código (hot reload), `R` reinicia la aplicación y `q` la cierra.

La aplicación arranca como visitante: inicia sesión desde el menú con la cuenta creada en el paso 1.

Las vistas previas de `lib/screens/previews/` y `lib/widgets/previews/` inician sesión con una cuenta que se les pasa al ejecutarlas:

```bash
flutter run -d chrome --web-port 58315 -t lib/screens/previews/list_user_test.dart --dart-define=PREVIEW_EMAIL=admin@lablend.test --dart-define=PREVIEW_PASSWORD=<contraseña>
```

## 3. Ejecutar la aplicación en Android (opcional)

Abre un emulador desde Android Studio y, dentro de `frontend/`:

```bash
flutter run
```

En el emulador, la aplicación usa `http://10.0.2.2:8000`, que es la dirección de tu computadora vista desde el emulador (`frontend/lib/settings.dart`).

## 4. Pruebas y análisis de estilo

Con el backend levantado:

```bash
docker compose -f backend/docker-compose.yml run --rm app_new sh -c "python manage.py wait_for_db && python manage.py test"
```

```bash
docker compose -f backend/docker-compose.yml run --rm app_new flake8
```

## 5. Despliegue en producción

Los valores por defecto de `backend/app/app/settings.py` son para desarrollo local. Antes de desplegar, define estas variables de entorno en el servidor:

| Variable | Valor en producción | Si no se define |
| --- | --- | --- |
| `CORS_ALLOWED_ORIGINS` | El origen del sistema, por ejemplo `https://lablend.example.edu`; varios orígenes separados por comas | Solo se aceptan `http://localhost:58315` y `http://localhost:65420`, así que el navegador bloquea la aplicación web servida desde el dominio real |

Después del primer despliegue, crea la cuenta inicial en el servidor con `python manage.py create_initial_admin` (ver [Crear la cuenta inicial](#crear-la-cuenta-inicial)) y guarda la contraseña en el gestor de contraseñas del equipo.

## Problemas comunes

| Síntoma | Causa | Solución |
| --- | --- | --- |
| La aplicación muestra "Sin conexión" | El backend no está corriendo en el puerto 8000 | Levántalo (paso 1) y revisa http://localhost:8000/health_check |
| La consola del navegador muestra un error CORS, o guardar un cambio responde 403 | La aplicación web corre en un puerto que no está en `CORS_ALLOWED_ORIGINS` ni en `CSRF_TRUSTED_ORIGINS` | Ejecútala con `--web-port 58315` |
| El inicio de sesión responde 429 | Límite de 3 inicios de sesión por minuto por usuario; cada reinicio de la aplicación cuenta como uno | Espera un minuto; usa `r` en lugar de `R` mientras editas |
| `docker compose up` falla porque el puerto 8000 está ocupado | Otro programa o contenedor usa ese puerto | Detén el otro proceso o contenedor |
