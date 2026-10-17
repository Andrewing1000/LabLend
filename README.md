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

### Configurar las variables de entorno (solo la primera vez)

El backend lee sus secretos de `backend/.env`, que no se sube a git. Desde la raíz del repositorio, crea el archivo a partir de la plantilla:

```bash
cp backend/.env.example backend/.env
```

Genera un valor aleatorio con este comando. Ejecútalo dos veces: un valor es para `DJANGO_SECRET_KEY` y el otro para `DB_PASS`:

```bash
docker run --rm python:3.12-alpine3.23 python -c "import secrets; print(secrets.token_urlsafe(50))"
```

| Variable en `backend/.env` | Valor | Si falta |
| --- | --- | --- |
| `DJANGO_SECRET_KEY` | Un valor generado | El backend no arranca (`ImproperlyConfigured: Falta DJANGO_SECRET_KEY`) |
| `DB_NAME`, `DB_USER` | Ya vienen en la plantilla (`devdb`, `devuser`) | `docker compose` se detiene con `Falta DB_NAME en backend/.env` (o `DB_USER`) |
| `DB_PASS` | El otro valor generado | `docker compose` se detiene con `Falta DB_PASS en backend/.env` |
| `DJANGO_DEBUG` | Ya viene en la plantilla (`True`): muestra el detalle de los errores mientras desarrollas | DEBUG queda desactivado y el backend exige las variables de producción (sección 5) |
| `DJANGO_ALLOWED_HOSTS` | Ya viene en la plantilla (`localhost,127.0.0.1,10.0.2.2`). Para probar desde un teléfono físico en tu red, agrega la IP de tu computadora | Django responde 400 (Bad Request) a las peticiones que llegan por otra dirección |

Cada instalación usa sus propios valores: no los compartas ni los subas a git.

> **Si ya tenías un `backend/.env` anterior:** agrégale las líneas `DJANGO_DEBUG` y `DJANGO_ALLOWED_HOSTS` de la plantilla (`backend/.env.example`). Sin ellas el backend no arranca (`ImproperlyConfigured: Falta DJANGO_ALLOWED_HOSTS`).

> **Si ya tenías una base de datos local creada con la contraseña `changeme`:** PostgreSQL guarda la contraseña al crear la base, así que cambiar `DB_PASS` no basta. Elige una opción:
>
> - Conservar los datos: después de completar `backend/.env`, levanta solo la base y cámbiale la contraseña al valor de `DB_PASS` (dentro del contenedor no se pide la contraseña anterior):
>
>   ```bash
>   docker compose -f backend/docker-compose.yml up -d db
>   ```
>
>   ```bash
>   docker compose -f backend/docker-compose.yml exec db psql -U devuser -d devdb -c "ALTER USER devuser WITH PASSWORD '<valor de DB_PASS>'"
>   ```
>
> - Empezar de cero (borra los datos locales): `docker compose -f backend/docker-compose.yml down -v`

### Iniciar

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

El sistema no trae cuentas predefinidas: las migraciones solo crean los roles, así que la base de datos empieza sin usuarios. Con el backend levantado, crea el administrador de seguridad inicial:

```bash
docker compose -f backend/docker-compose.yml run --rm app_new python manage.py create_initial_admin --email admin@lablend.test --nombres "Juan Carlos" --apellido-paterno "Pérez" --apellido-materno "Gutiérrez"
```

- **Correo y nombre:** los que pases al comando. `--apellido-materno` es opcional.
- **Código de usuario:** es la credencial para iniciar sesión (el correo ya no sirve para entrar). El comando lo genera y lo muestra: `adm.` + inicial del primer nombre + apellido paterno, en minúsculas y sin tildes ni ñ (en el ejemplo, `adm.jperez`). Las cuentas creadas desde la aplicación reciben el prefijo `usr.` (por ejemplo `usr.mquispe`), y si el código ya existe se le agrega un número (`usr.mquispe2`). El código no cambia aunque después se edite el nombre.
- **Contraseña:** el comando la genera al azar, cumpliendo la política de contraseñas, y la muestra **una sola vez** en la terminal. Guárdala de inmediato en el gestor de contraseñas: la base de datos solo guarda su hash, así que no hay forma de volver a verla. Nadie la conoce de antemano y no está en el código ni en git.
- **Rol:** administrador de seguridad. Gestiona las cuentas y consulta la bitácora de sesiones, pero no el inventario ni los préstamos (D18).
- **Solo una vez:** el comando se niega a ejecutarse si ya existe un administrador de seguridad. Las demás cuentas, administradores de laboratorio y asistentes, se crean desde la aplicación con esa cuenta. Para gestionar el inventario, crea primero un administrador de laboratorio.

Si se pierde la contraseña del administrador de seguridad, cámbiala desde el servidor; el comando pide la nueva contraseña y aplica la misma política:

```bash
docker compose -f backend/docker-compose.yml run --rm app_new python manage.py changepassword adm.jperez
```

> Si tu base de datos es anterior a este cambio, todavía tiene la cuenta `admin@example.com`, cuya contraseña está publicada en el historial de git. Desactívala, o empieza con una base vacía con `down -v` (borra también los datos locales).

> **Si tu base de datos tiene usuarios creados antes del código de usuario:** esas cuentas no reciben un código y no pueden iniciar sesión, y la migración `0007` falla si hay más de una. Empieza con una base vacía con `down -v` y vuelve a crear la cuenta inicial.

> **No hay superusuarios:** `python manage.py createsuperuser` está deshabilitado y responde con un error; toda cuenta tiene un rol. Si tu base de datos tenía un superusuario creado con ese comando, después de las migraciones queda sin rol y sin permisos: crea la cuenta inicial con `create_initial_admin`.

> **Si tu cuenta inicial se creó antes del rol de administrador de seguridad:** sigue siendo administrador de laboratorio y ya no puede gestionar cuentas. Con el backend levantado (las migraciones crean el rol nuevo), vuelve a ejecutar `create_initial_admin` con otro correo: crea el administrador de seguridad, y la cuenta anterior queda como administrador de laboratorio.

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

La aplicación arranca como visitante: inicia sesión desde el menú con el código de usuario y la contraseña de la cuenta creada en el paso 1.

Las vistas previas de `lib/screens/previews/` y `lib/widgets/previews/` inician sesión con una cuenta que se les pasa al ejecutarlas:

```bash
flutter run -d chrome --web-port 58315 -t lib/screens/previews/list_user_test.dart --dart-define=PREVIEW_USER=adm.jperez --dart-define=PREVIEW_PASSWORD=<contraseña>
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

Las pruebas tardan cerca de un minuto y medio: cada cuenta que crean guarda su contraseña con Argon2id y en el historial de contraseñas, con los mismos parámetros que en producción.

```bash
docker compose -f backend/docker-compose.yml run --rm app_new flake8
```

## 5. Despliegue en producción

En producción no se usa `backend/.env` de desarrollo: define estas variables de entorno en el servidor. Sin `DJANGO_DEBUG`, el backend arranca en modo producción y se niega a arrancar si falta alguna variable obligatoria:

| Variable | Valor en producción | Si no se define |
| --- | --- | --- |
| `DJANGO_SECRET_KEY` | Una clave nueva generada para producción con el comando del paso 1, distinta de la de desarrollo, guardada en el gestor de contraseñas | El servidor no arranca |
| `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS` | Los datos de la base de datos de producción, con una contraseña generada para producción y guardada en el gestor de contraseñas; nunca `changeme` ni la de desarrollo | El servidor no puede conectarse a la base de datos |
| `DJANGO_DEBUG` | No se define (o `False`). Nunca `True`: mostraría el código y la configuración ante un error | — (desactivado, que es lo correcto) |
| `DJANGO_ALLOWED_HOSTS` | El dominio del servidor, por ejemplo `lablend.example.edu`; varios separados por comas | El servidor no arranca |
| `CORS_ALLOWED_ORIGINS` | El origen de la aplicación web, por ejemplo `https://lablend.example.edu`; varios separados por comas. Vacía (`CORS_ALLOWED_ORIGINS=`) si la aplicación y la API se sirven desde el mismo dominio | El servidor no arranca |

Antes de abrir el sistema a los usuarios, revisa la configuración con la lista de verificación de Django y corrige lo que reporte:

```bash
python manage.py check --deploy
```

Las contraseñas se guardan con Argon2id, que usa unos 100 MiB de memoria y unos 100 ms por cada inicio de sesión o cambio de contraseña. Elige un servidor con memoria suficiente para los inicios de sesión simultáneos que esperas, más la que usa Django.

Después del primer despliegue, crea la cuenta inicial en el servidor con `python manage.py create_initial_admin` (ver [Crear la cuenta inicial](#crear-la-cuenta-inicial)) y guarda la contraseña en el gestor de contraseñas del equipo.

## Problemas comunes

| Síntoma | Causa | Solución |
| --- | --- | --- |
| `docker compose` dice que no encuentra `backend/.env` | Falta el archivo de variables de entorno | Créalo desde la plantilla (paso 1) |
| El backend termina con `ImproperlyConfigured: Falta DJANGO_SECRET_KEY` | `DJANGO_SECRET_KEY` no está definida o está vacía en `backend/.env` | Genera una clave y pégala (paso 1) |
| El backend termina con `ImproperlyConfigured: Falta DJANGO_ALLOWED_HOSTS` o `Falta CORS_ALLOWED_ORIGINS` | DEBUG está desactivado (falta `DJANGO_DEBUG=True` en `backend/.env`) y no están las variables de producción | En desarrollo, agrega `DJANGO_DEBUG` y `DJANGO_ALLOWED_HOSTS` de la plantilla (paso 1); en producción, define las variables de la sección 5 |
| Una petición responde 400 (Bad Request) sin más detalle | La dirección por la que llega no está en `DJANGO_ALLOWED_HOSTS` | Agrégala a `DJANGO_ALLOWED_HOSTS` en `backend/.env` |
| `docker compose` se detiene con `Falta DB_PASS en backend/.env` (o `DB_NAME`, `DB_USER`) | La variable no está en `backend/.env` o está vacía | Complétala (paso 1) |
| El backend se detiene al aplicar las migraciones con `password authentication failed for user "devuser"` | La base local se creó con otra contraseña (por ejemplo, `changeme`) | Cambia la contraseña en la base o empieza de cero (nota del paso 1) |
| La aplicación muestra "Sin conexión" | El backend no está corriendo en el puerto 8000 | Levántalo (paso 1) y revisa http://localhost:8000/health_check |
| La consola del navegador muestra un error CORS, o guardar un cambio responde 403 | La aplicación web corre en un puerto que no está en `CORS_ALLOWED_ORIGINS` ni en `CSRF_TRUSTED_ORIGINS` | Ejecútala con `--web-port 58315` |
| El inicio de sesión responde 429 | Límite de 3 inicios de sesión por minuto por usuario; cada reinicio de la aplicación cuenta como uno | Espera un minuto; usa `r` en lugar de `R` mientras editas |
| El backend termina con `Couldn't load 'Argon2PasswordHasher' algorithm library: No module named 'argon2'` | La imagen se construyó antes de que se agregara `argon2-cffi` a `requirements.txt` | Reconstruye la imagen: `docker compose -f backend/docker-compose.yml up --build` |
| Una cuenta de tu base local ya no puede iniciar sesión con su contraseña correcta | La cuenta se creó antes de que las contraseñas se guardaran con Argon2id; su hash usa otro algoritmo, que ya no se acepta | Asígnale una contraseña nueva con `python manage.py changepassword <código de usuario>` (ver [Crear la cuenta inicial](#crear-la-cuenta-inicial)), o empieza de cero (nota del paso 1) |
| `docker compose up` falla porque el puerto 8000 está ocupado | Otro programa o contenedor usa ese puerto | Detén el otro proceso o contenedor |
