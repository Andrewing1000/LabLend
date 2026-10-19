# Proyecto de Ética y Seguridad de Sistemas 2-2026 — LabLend

## 1. Carátula

**Universidad Católica Boliviana "San Pablo"**

Ingeniería de Sistemas

**SIS-325 Ética y Seguridad de Sistemas**

Evaluación 2 basada en proyectos

**Proyecto: Reingeniería de seguridad del sistema LabLend**

Sistema de inventario y préstamo de equipos de laboratorio

**Docente:** Mgr. Ing. Lourdes Peredo Quiroga

**Grupo:** [nombre del grupo]

**Integrantes:** [integrante 1], [integrante 2], [integrante 3]

**Lugar y fecha:** [ciudad], [fecha de entrega]

## 2. Introducción

LabLend es un sistema que digitaliza el inventario y el préstamo de equipos de un laboratorio universitario, y este proyecto aplica sobre él una reingeniería de seguridad. Cuando el préstamo se controla en cuadernos u hojas de cálculo, se pierde la trazabilidad de quién tiene cada equipo, cuántas unidades quedan y cuándo deben volver.

El sistema se desarrolló en 2024 como una API REST en Django con una aplicación Flutter para web y móvil. Se construyó priorizando la funcionalidad, por lo que presenta debilidades de seguridad: credenciales escritas en el código fuente, roles fijos programados en lugar de administrables, una política de contraseñas incompleta y cookies de sesión sin protecciones suficientes.

Este documento describe el sistema en las secciones 3 a 7. Las secciones 8 a 10 documentan la reingeniería de seguridad realizada en el marco de SIS-325: las deficiencias encontradas y su corrección; la gestión de usuarios, roles y contraseñas; y la aplicación de los principios de diseño seguro y las reglas de oro de OWASP. Cada punto se acompaña de capturas del sistema en funcionamiento. Los enlaces al código fuente y al sistema publicado están en la sección Enlaces.

## 3. Nombre y descripción del sistema

**Nombre:** LabLend (de *Lab*, laboratorio, y *Lend*, prestar).

LabLend es un sistema web y móvil para administrar el inventario de equipos de un laboratorio y registrar sus préstamos y devoluciones. Está orientado al Laboratorio de Física de la UCB, cuyo correo institucional aparece en la configuración del sistema.

Tiene dos partes: una API REST en Django que guarda los datos en PostgreSQL, y una aplicación Flutter que se compila para navegador web, Android, iOS y escritorio. Ambas se comunican por HTTP con mensajes JSON, una cookie de sesión y un token CSRF.

**Usuarios del sistema**

| Rol | Quién es | Qué puede hacer |
| --- | --- | --- |
| Visitante (sin sesión) | Estudiante, docente o cualquier persona | Consultar el catálogo de equipos y buscar por nombre, marca y categoría |
| Asistente de laboratorio | Auxiliar que atiende el laboratorio | Iniciar sesión, registrar préstamos, ver y cerrar sus propios préstamos, editar su perfil |
| Administrador de laboratorio | Encargado del laboratorio | Lo anterior, más gestionar equipos, marcas y categorías, y ver todos los préstamos |
| Administrador de seguridad | Responsable de las cuentas; la cuenta inicial se crea al instalar el sistema | Crear, modificar y desactivar cuentas; crear, modificar y eliminar roles y asignarlos a las cuentas (D15); consultar la bitácora de sesiones y la bitácora de seguridad (D28). No gestiona el inventario ni los préstamos (D18) |
**Funcionamiento general**

1. El visitante abre la aplicación y consulta el catálogo sin iniciar sesión.
2. El personal inicia sesión con su código de usuario (por ejemplo, `usr.jperez`) y su contraseña; el servidor abre una sesión de 15 minutos y registra la hora de ingreso.
3. Para prestar, el usuario agrega equipos y cantidades a un carrito y define las fechas de préstamo y devolución.
4. El servidor verifica que haya unidades disponibles (cantidad total menos cantidad prestada) y, si las hay, registra el préstamo y aumenta la cantidad prestada.
5. Al marcar el préstamo como devuelto, las unidades vuelven a quedar disponibles.
6. Al cerrar sesión se registra la hora de salida, que el administrador puede consultar.

## 4. Objetivo del sistema

**Objetivo general:** controlar el inventario y los préstamos de equipos del laboratorio en un sistema centralizado, de modo que en todo momento se sepa qué equipos existen, cuántas unidades están prestadas, a quién y hasta qué fecha.

**Objetivos específicos:**

1. Mantener un catálogo de equipos con marca, categorías, número de serie, imagen, enlace a ficha técnica y cantidad disponible.
2. Registrar cada préstamo con responsable, fecha de préstamo, fecha de devolución y cantidades, validando la disponibilidad antes de aceptarlo.
3. Actualizar automáticamente las unidades prestadas al registrar un préstamo y al marcarlo como devuelto.
4. Restringir las operaciones según el rol del usuario y permitir la consulta pública del catálogo.
5. Registrar el inicio y cierre de sesión de cada usuario para fines de auditoría.
6. Ofrecer la misma funcionalidad en navegador web y en dispositivos móviles.

## 5. Tecnología utilizada

LabLend usa una arquitectura cliente-servidor de tres capas: un cliente Flutter, una API REST en Django y una base de datos PostgreSQL, con el servidor y la base de datos en contenedores Docker.

![Arquitectura de LabLend · 3 capas](img/arquitectura.png)

La aplicación Flutter nunca accede directamente a la base de datos: cada operación pasa por la API, que aplica CORS, sesión, CSRF y permisos por rol antes de tocar los datos. Solo la consulta del catálogo es pública.

| Capa | Tecnología | Uso en LabLend |
| --- | --- | --- |
| Servidor | Python 3.12 | Lenguaje del servidor |
| Servidor | Django 5.2 LTS | Framework web: ORM, autenticación, sesiones, protección CSRF y panel de administración |
| Servidor | Django REST Framework 3.18 | API REST, clases de permiso por rol y limitación de solicitudes (throttling) |
| Servidor | django-filter 26.2 | Filtros de búsqueda de equipos, préstamos y usuarios |
| Servidor | django-password-validators 1.7 | Reglas de complejidad e historial de contraseñas |
| Servidor | argon2-cffi 25.1 | Hash de contraseñas con Argon2id |
| Servidor | django-cors-headers 4.9 | Control de orígenes cruzados (CORS) para el cliente web |
| Servidor | drf-spectacular 0.30 | Documentación OpenAPI y Swagger en /api/docs/ |
| Servidor | Pillow 12.3 | Validación y manejo de las imágenes de los equipos |
| Base de datos | PostgreSQL 17 (psycopg2 2.9) | Almacenamiento; búsqueda por similitud de texto con la extensión pg_trgm |
| Cliente | Flutter con Dart 3.3 o superior | Una sola base de código para web, Android, iOS, Windows, Linux y macOS |
| Cliente | dio 5.1, cookie_jar 4.0, dio_cookie_manager 3.1 | Cliente HTTP y manejo de la cookie de sesión y el token CSRF |
| Cliente | flutter_secure_storage 5.0 | Almacenamiento cifrado del token CSRF en móviles |
| Cliente | provider 6.1 | Manejo del estado de la aplicación |
| Cliente | file_picker 5.0 | Selección de imágenes al registrar equipos |
| Infraestructura | Docker y Docker Compose | Contenedor de la API (Alpine Linux) y contenedor de PostgreSQL |
| Herramientas | Git y GitHub | Control de versiones del código |
| Herramientas | flake8 7 | Análisis estático de estilo del código Python |

## 6. Problemas o necesidades que el sistema resuelve

LabLend reemplaza el control manual del préstamo de equipos, que no permite saber con certeza qué está disponible, quién tiene cada equipo ni quién hizo cada registro.

| Problema o necesidad | Cómo lo resuelve LabLend |
| --- | --- |
| Los préstamos se anotan en cuadernos u hojas sueltas, fáciles de perder o alterar | Cada préstamo queda en la base de datos con responsable, fechas, equipos y cantidades |
| No se sabe cuántas unidades de un equipo quedan disponibles | El sistema lleva la cantidad total y la prestada de cada equipo, y rechaza un préstamo que excede lo disponible |
| Hay equipos que no se devuelven a tiempo | La fecha de devolución es obligatoria y posterior a la de préstamo; se pueden filtrar los préstamos no devueltos por rango de fechas |
| Estudiantes y docentes deben ir al laboratorio para preguntar qué equipos existen | Catálogo público con búsqueda por nombre, marca y categoría, con imagen y enlace a la ficha técnica |
| Cualquiera con acceso al cuaderno puede registrar o modificar un préstamo | Cuentas personales con contraseña y permisos según el rol |
| No queda constancia de quién operó el sistema ni cuándo | Bitácora con la hora de inicio y cierre de sesión de cada usuario |
| El personal atiende desde distintos dispositivos | La misma aplicación funciona en navegador, móvil y escritorio |

## 7. Funcionalidad del sistema (módulos y funciones)

Al terminar la reingeniería, LabLend tendrá 9 módulos: 7 que ya existen y 2 nuevos, gestión de roles y gestión de contraseñas. Las funciones y los roles describen el sistema terminado; la columna Estado indica el avance al 18 de octubre de 2026.

| Módulo | Funciones | Roles con acceso | Ruta en la API | Estado |
| --- | --- | --- | --- | --- |
| 1. Autenticación y sesión | Inicio de sesión con código de usuario (User ID) y contraseña; cierre de sesión; expiración de la sesión a los 15 minutos; mensaje de error genérico que no revela si el usuario existe | Todos los usuarios registrados | /user/token/, /user/logout/ | Implementado |
| 2. Perfil de usuario | Ver los datos propios y editar el nombre (el correo no se puede cambiar); cambiar la contraseña propia pidiendo la actual y validando la política | Todos los usuarios registrados | /user/me/ | Parcial: la contraseña propia se cambia desde el botón de llave de la barra superior, pidiendo la actual y validando la política; la aplicación aún no tiene una pantalla para editar el nombre propio |
| 3. Gestión de usuarios (ABM) | Listar usuarios con filtros por rol, estado y correo; crear, modificar y desactivar usuarios; código de usuario (User ID) con formato estándar | Administrador de seguridad | /user/list/, /user/create/, /user/create/admin/, /user/manage/ | Implementado |
| 4. Gestión de roles | Crear, modificar y eliminar roles; asignar permisos por función; asignar y quitar roles a usuarios; matriz de accesos | Administrador de seguridad | /user/roles/, /user/permissions/, /user/create/ y /user/manage/ (campo roles) | Implementado (D15, D16, D19): pantalla "Roles" para listar, crear, modificar y eliminar roles y elegir sus permisos, selección de roles en la creación y edición de cuentas, y vista de matriz de accesos |
| 5. Gestión de contraseñas | Política de complejidad y longitud; vencimiento; historial de contraseñas; bloqueo al tercer intento fallido; desbloqueo y reinicio por el administrador; contraseñas iniciales generadas y guardadas en un gestor de contraseñas | Administrador de seguridad | Por definir | Implementado (D20 a D26): regla de complejidad y longitud, vencimiento a los 90 días, historial de las últimas 5 contraseñas, bloqueo al tercer intento fallido, y activación de cuentas nuevas y restablecimiento con enlaces que genera el administrador de seguridad |
| 6. Bitácoras | Consultar las horas de inicio y cierre de sesión de un usuario; consultar la bitácora de seguridad (inicios de sesión fallidos, cambios de cuentas, acciones rechazadas) con filtros por usuario, tipo y fecha | Administrador de seguridad | /user/log/, /user/events/ | Implementado |
| 7. Inventario | Alta, edición y baja de equipos (nombre, descripción, enlace, número de serie, cantidad, imagen); gestión de marcas y categorías; búsqueda por similitud de nombre y filtros por marca y categoría | Administrador de laboratorio para editar; todos, incluso visitantes, para consultar | /item/items/, /item/brands/, /item/categories/, /item/list/ | Implementado |
| 8. Préstamos | Carrito de equipos; registro del préstamo con fechas y cantidades; validación de disponibilidad; marcar como devuelto; búsqueda por rango de fechas, estado y correo. El asistente ve solo sus préstamos y el administrador ve todos | Administrador de laboratorio, asistente | /loan/loan/ | Implementado |
| 9. Soporte técnico | Documentación interactiva Swagger y verificación del estado del servidor | Desarrolladores | /api/docs/, /health_check | Implementado; el panel /admin/ de Django se eliminó (D9) |

## 8. Alcance de la reingeniería del sistema

La revisión del código del servidor (backend/app) y de la aplicación (frontend/lib) encontró 31 deficiencias de seguridad, y la reingeniería planifica corregirlas todas. Cada fila indica la deficiencia, su corrección, la sección donde se demuestra y su categoría en el [OWASP Top 10:2025](https://top10.owasp.org/2025); la columna Estado indica el avance al 18 de octubre de 2026.

Categorías OWASP usadas: A01 Control de acceso roto, A02 Configuración de seguridad incorrecta, A03 Fallas en la cadena de suministro de software, A04 Fallas criptográficas, A06 Diseño inseguro, A07 Fallas de autenticación, A09 Fallas en el registro y las alertas de seguridad, A10 Manejo incorrecto de condiciones excepcionales. La revisión no encontró casos de A05 Inyección ni de A08 Fallas de integridad del software o de los datos: el código no usa SQL directo, y todas las consultas pasan por el ORM de Django, que trata los datos del usuario como parámetros. La descripción de cada categoría, en español y en inglés, y las deficiencias que le corresponden están en [owasp-top10.md](owasp-top10.md).

### 8.1 Configuración, secretos y despliegue

| N.º | Deficiencia encontrada | Corrección | Se demuestra en | OWASP | Estado |
| --- | --- | --- | --- | --- | --- |
| D1 | La clave secreta de Django (SECRET_KEY) está escrita en settings.py y publicada en GitHub | Leerla de la variable de entorno DJANGO_SECRET_KEY, sin valor por defecto (el servidor no arranca sin ella), y generar una nueva por instalación | 10 (seguridad por defecto) | A04 | Implementado |
| D2 | La contraseña del correo Gmail está en settings.py, y docker-compose.yml usa las credenciales de base de datos de ejemplo (changeme) | Credenciales de base de datos en variables de entorno (archivo .env fuera del repositorio); eliminar la configuración de Gmail, que el sistema no usa; cambiar las contraseñas expuestas, que siguen en el historial de git | 10 (seguridad por defecto, minimizar la superficie de ataque) | A02 | Implementado |
| D3 | Cada migración crea un superusuario con correo y contraseña fijos, escritos en core/models.py y core/signals.py | Eliminar la creación automática; la cuenta inicial es un administrador de seguridad creado con un comando (create_initial_admin), con una contraseña generada y guardada en el gestor de contraseñas | 9.3 y 10 (mecanismo menos común) | A07 | Implementado |
| D4 | La aplicación Flutter inicia sesión como superadministrador al arrancar, con esa contraseña escrita en frontend/lib/main.dart, así que todos los usuarios comparten la misma cuenta | Eliminar el inicio automático: cada persona entra por la pantalla de login con su propia cuenta; las vistas previas de desarrollo reciben la cuenta con --dart-define | 10 (mecanismo menos común) | A07 | Implementado |
| D5 | DEBUG=True: ante un error, el servidor muestra el código, la configuración y las rutas | DEBUG desactivado por defecto (solo se activa con DJANGO_DEBUG en desarrollo) y ALLOWED_HOSTS limitado al dominio del hosting (DJANGO_ALLOWED_HOSTS); sin DEBUG, el servidor no arranca si faltan los dominios permitidos o los orígenes de CORS | 10 (fallar de forma segura, seguridad por defecto) | A02 | Implementado |
| D6 | CORS acepta peticiones con credenciales desde cualquier origen | Aceptar solo el dominio del sistema, configurado en la variable de entorno CORS_ALLOWED_ORIGINS | 10 (minimizar la superficie de ataque) | A01 | Implementado |
| D7 | La cookie de sesión se puede leer desde JavaScript (SESSION_COOKIE_HTTPONLY=False) | Cookie HttpOnly y SameSite=Lax, sirviendo la aplicación y la API desde el mismo dominio | 10 (defensa en profundidad) | A02 | Implementado |
| D8 | El sistema funciona por HTTP con el servidor de desarrollo de Django (runserver) | HTTPS del hosting con HSTS y redirección, y un servidor de producción (Gunicorn) | 10 (seguridad por defecto) | A04 | Pendiente |
| D9 | El panel de administración de Django está activo en /admin/ y permite gestionar usuarios fuera de la aplicación | Eliminar el panel en todos los entornos, no solo en producción: se quitan la ruta /admin/ y la aplicación django.contrib.admin, así que /admin/ responde 404. Usuarios y roles se gestionan solo desde la aplicación, donde pasan por los permisos y el registro de sesiones | 10 (minimizar la superficie de ataque) | A02 | Implementado |
| D10 | Django 3.2 y Pillow 8.2 ya no reciben parches de seguridad (Django 3.2 perdió soporte en abril de 2024) | Actualizar a Django 5.2 LTS con Python 3.12 y PostgreSQL 17, y a versiones con soporte de las demás librerías | 10 (seguridad por defecto) | A03 | Implementado |

### 8.2 Usuarios y autenticación

| N.º | Deficiencia encontrada | Corrección | Se demuestra en | OWASP | Estado |
| --- | --- | --- | --- | --- | --- |
| D11 | No existe un código de usuario: se inicia sesión con el correo | Código de usuario (User ID) con formato estándar, generado al crear la cuenta y usado para iniciar sesión: prefijo + inicial del primer nombre + apellido paterno, en minúsculas y sin tildes ni ñ. El administrador de seguridad usa `adm.` (`adm.jperez`) y los demás usuarios `usr.` (`usr.mquispe`); si el código ya existe se agrega un número (`usr.mquispe2`). El nombre se guarda en tres campos (nombres, apellido paterno y apellido materno) para no confundir apellidos compuestos (`usr.jdelacruz`). El código no se puede elegir ni cambiar, y el correo deja de servir para iniciar sesión | 9.1 | — (requisito del curso) | Implementado |
| D12 | El login responde distinto si el correo no existe (404) o si la contraseña es incorrecta (401), lo que permite averiguar qué correos están registrados | Un solo mensaje genérico para ambos casos: el login responde 401 con "Código de usuario o contraseña incorrectos" si el código no existe, si la contraseña es incorrecta, si la cuenta está desactivada o si está bloqueada (D23). El servidor verifica la contraseña también para códigos inexistentes, así el tiempo de respuesta no los delata, y el límite de 3 intentos por minuto se aplica a cualquier código, exista o no | 10 (fallar de forma segura) | A07 | Implementado |
| D13 | Un administrador de laboratorio puede editar cualquier cuenta, incluida la del superadministrador, y cambiarle la contraseña (/user/manage/) | Solo el administrador de seguridad gestiona cuentas (resuelto con D18): el administrador de laboratorio recibe 403 en /user/manage/ y en los demás endpoints de cuentas. Como hay un único nivel de administración de cuentas, no existen cuentas con más privilegios que el administrador de seguridad; la protección de las cuentas de administrador de seguridad entre sí y la eliminación del superusuario quedan en D27 | 9.1 y 10 (mínimo privilegio) | A01 | Implementado |
| D14 | Un usuario puede cambiar su correo y su contraseña sin confirmar la contraseña actual (/user/me/) | Pedir la contraseña actual para cambiar la contraseña. El correo no se puede cambiar: se fija al crear la cuenta, como el código de usuario, y ni el usuario ni el administrador de seguridad lo modifican, así que una sesión robada o un administrador no pueden cambiar los datos que identifican a la persona. El administrador de seguridad ya no escribe contraseñas ajenas: para una cuenta ajena genera un enlace de restablecimiento (D24). Implementación: /user/me/ y /user/manage/ responden 400 "El correo no se puede cambiar." si la petición trae un correo distinto del actual (enviar el mismo se acepta, porque la aplicación envía la cuenta completa; la pantalla de edición ya mostraba el correo sin permitir editarlo). /user/me/ exige el campo `current_password` cuando la petición cambia la contraseña (cambiar solo el nombre no lo pide); sin él responde 400 "Ingrese su contraseña actual para cambiar la contraseña." y, si es incorrecta, 400 "La contraseña actual es incorrecta." y lo registra en la bitácora de seguridad. La contraseña actual se verifica antes que la política, porque el historial (D22) respondería si una contraseña probada es la actual. Para que /user/me/ no sirva para adivinar contraseñas fuera del límite del login, se aceptan 3 intentos por minuto con `current_password` por usuario (429 al cuarto). /user/manage/ responde 400 si la petición trae una contraseña y la pantalla de edición ya no muestra el campo; en su lugar tiene el botón para generar el enlace (D24) | 9.3 | A07 | Implementado |
| D30 | La API acepta credenciales HTTP Basic en cualquier endpoint (configuración por defecto de Django REST Framework), y esa verificación ocurre antes del límite de intentos, así que se pueden probar contraseñas sin pasar por el login ni su límite de 3 intentos por minuto | Aceptar solo la autenticación por sesión que se obtiene en /user/token/ | 10 (economía del mecanismo, mediación completa) | A07 | Implementado |
| D31 | La pantalla de login muestra un botón con el logo de inicio de sesión de Google que no autentica: solo abre accounts.google.com en otra pestaña, lo que hace creer que existe un segundo método de ingreso y acostumbra a los usuarios a escribir sus credenciales en una página a la que los envía la aplicación | Quitar el botón: el único método de ingreso es el código de usuario y la contraseña | 10 (menos asombro, minimizar la superficie de ataque) | A06 | Implementado |

### 8.3 Roles y permisos

| N.º | Deficiencia encontrada | Corrección | Se demuestra en | OWASP | Estado |
| --- | --- | --- | --- | --- | --- |
| D15 | Solo hay dos roles fijos en el código (core/models.py), y no se pueden crear, editar ni eliminar roles | Control de acceso basado en roles (RBAC): roles guardados en la base de datos, con permisos por función, administrados desde la aplicación; un usuario puede tener uno o varios roles. Implementación: tablas de permisos y de roles, y una relación de varios roles por usuario; los permisos del usuario son la unión de los de sus roles, y no hay permisos ni grupos asignados al usuario directamente. El catálogo tiene 11 permisos, uno por función, en dos áreas: seguridad (ver, crear y modificar usuarios, asignar roles, generar enlaces, ver bitácoras, ver roles, gestionar roles) y laboratorio (gestionar inventario, registrar préstamos, ver todos los préstamos). Las migraciones crean los tres roles anteriores con sus permisos y cada usuario conserva su rol. El administrador de seguridad lista, crea, modifica y elimina roles en /user/roles/, consulta el catálogo en /user/permissions/, y asigna y quita roles en /user/manage/ (campo roles) o al crear la cuenta. Reglas: un rol no mezcla permisos de seguridad y de laboratorio; un rol con usuarios no se elimina ni puede ganar o perder permisos de seguridad; los nombres no se repiten. Cada creación, cambio y eliminación de un rol queda en la bitácora de seguridad (D28). En la aplicación, la opción "Roles" del menú (permiso ver_roles) lista los roles con su área, sus permisos y cuántas cuentas los tienen; quien tiene gestionar_roles crea, modifica y elimina roles marcando sus permisos agrupados por área. La pantalla aplica las mismas reglas que el servidor: al marcar un permiso de un área se deshabilitan los de la otra, el rol protegido se muestra de solo lectura, y los mensajes de rechazo del servidor (por ejemplo, eliminar un rol con usuarios) se muestran tal cual. En la creación y edición de cuentas, los roles se eligen de una lista (varios a la vez); los de seguridad solo al crear la cuenta, y nunca junto a uno de laboratorio. Se eliminaron los restos del modelo anterior: el campo role_field, el filtro is_admin y la ruta /user/create/admin/; una cuenta se crea en /user/create/ con los roles indicados, o sin roles | 9.2 | A01 | Implementado |
| D16 | Cada vista compara el nombre del rol por su cuenta (IsLabAdmin), y los permisos declarados en el modelo LabAdmin no se usan | Un único mecanismo que verifica, en cada petición, el permiso de la función solicitada. Implementación: una sola clase de permiso (RolePermission, en core/permissions.py) es la de todas las vistas por defecto; exige una sesión abierta y el permiso que cada vista declara, con uno para leer y otro para escribir cuando hace falta. Una vista que no declara su permiso no se puede usar (falla de forma segura). Solo las vistas públicas (catálogo, inicio de sesión, enlaces de contraseña, verificación de estado y documentación) la reemplazan, y una prueba recorre todas las rutas de la API para comprobarlo. Se eliminaron IsLabAdmin, IsSecurityAdmin, IsLabStaff y las comparaciones de nombres de rol: el administrador de laboratorio ve todos los préstamos por el permiso ver_todos_prestamos, no por el nombre de su rol. Un cambio en los permisos de un rol rige desde la siguiente petición | 9.2 y 10 (economía del mecanismo, mediación completa) | A01 | Implementado |
| D17 | La aplicación Flutter arma su menú con nombres de rol fijos (frontend/lib/models/User.dart) y muestra opciones que el servidor luego rechaza, como marcas y categorías al asistente | Menú construido a partir de los permisos que devuelve el servidor. Implementación: el inicio de sesión y /user/me/ devuelven los roles y los permisos de la cuenta, y la aplicación decide cada opción del menú y cada botón (agregar, editar y eliminar equipos; carrito de préstamos; buscar entre los préstamos de todos; crear cuentas; generar enlaces) por el permiso de su función, no por el nombre del rol. Así el asistente ya no ve marcas y categorías, el administrador de seguridad ya no ve el carrito, y una cuenta con un rol creado desde la aplicación inicia sesión y ve exactamente lo que sus permisos permiten (antes la aplicación la trataba como visitante). Antes de cada petición la aplicación también verifica el permiso, pero quien decide es el servidor (D16). Al verificar la sesión, la aplicación lee de nuevo los permisos, así que un cambio en los roles de la cuenta se refleja en el menú sin volver a iniciar sesión | 9.2 y 10 (menos asombro) | A01 | Implementado |
| D18 | El mismo administrador gestiona el inventario y las cuentas de usuario | Rol de administrador de seguridad, separado del administrador de laboratorio, y una regla que impide asignar ambos roles al mismo usuario. El administrador de seguridad gestiona las cuentas y consulta la bitácora de sesiones, pero no el inventario ni los préstamos; el administrador de laboratorio gestiona el inventario y ve todos los préstamos, pero ya no las cuentas. El rol de administrador de seguridad no se puede asignar ni quitar a una cuenta existente (la API responde 400): lo tienen la cuenta inicial (create_initial_admin) y las cuentas creadas con ese rol desde la aplicación (D15), siempre con el prefijo `adm.`. Así nadie tiene a la vez ese rol y uno del laboratorio. Con varios roles por usuario (D15) la regla se mantiene por áreas: los roles con permisos de seguridad solo se dan al crear la cuenta, y la API rechaza con 400 cualquier combinación de roles de seguridad y de laboratorio en una cuenta | 9.2 y 10 (segregación de roles) | A01 | Implementado |
| D19 | No existe una matriz de accesos documentada | Matriz de accesos por rol y función, verificable en la aplicación. Implementación: la matriz de esta sección, con la ruta de la API que exige cada permiso, y la vista "Matriz de accesos" de la pantalla "Roles", que la arma con los roles y el catálogo de permisos del servidor, así que también muestra los roles creados desde la aplicación | 9.2 | A01 | Implementado |
| D27 | El superusuario de Django pasa todas las comprobaciones de permisos, y el código le agrega excepciones explícitas (isAdmin e IsLogged en core/models.py) | Eliminar el superusuario: ninguna cuenta queda fuera de RBAC. El rol de administrador de seguridad queda protegido: no se puede eliminar; un administrador de seguridad no puede modificar ni desactivar la cuenta de otro administrador de seguridad (cada uno cambia solo sus propios datos, desde su perfil), y no se puede desactivar al último administrador de seguridad activo, para que el sistema nunca quede sin quien gestione las cuentas. Implementación: se eliminan los campos is_superuser e is_staff, el método create_superuser y las excepciones para superusuarios en isAdmin e IsLogged; el comando createsuperuser se reemplaza por uno que se niega a ejecutarse. /user/manage/ responde 403 a cualquier cambio sobre una cuenta de administrador de seguridad, la propia incluida. El modelo rechaza desactivar al último administrador de seguridad activo, también desde la consola del servidor. Borrar el rol de administrador de seguridad se rechaza siempre, y borrar un rol con usuarios falla en lugar de borrar a sus usuarios en cascada | 9.2 y 10 (mínimo privilegio, mediación completa) | A01 | Implementado |

#### Matriz de accesos (D19)

La matriz muestra qué funciones puede usar cada rol por defecto. Cada función de la API corresponde a un permiso del catálogo (backend/app/core/rbac.py), y la columna Rutas indica dónde lo exige el servidor (D16). En la aplicación, la pantalla "Roles", opción "Matriz de accesos", muestra la misma matriz con los datos del servidor, incluidos los roles creados desde la aplicación.

| Función | Permiso | Rutas de la API | Visitante (sin sesión) | Administrador de seguridad | Administrador de laboratorio | Asistente de laboratorio |
| --- | --- | --- | --- | --- | --- | --- |
| Consultar el catálogo de equipos, marcas y categorías | Público | /item/list/items/, /item/list/brands/, /item/list/categories/ | Sí | Sí | Sí | Sí |
| Elegir la contraseña con un enlace de activación o de restablecimiento | Público, con el enlace | /user/password-link/check/, /user/password-link/ | Sí | Sí | Sí | Sí |
| Iniciar sesión | Público | /user/token/ | Sí | Sí | Sí | Sí |
| Ver y editar el perfil propio, cambiar la contraseña propia, cerrar sesión | Sesión abierta | /user/me/, /user/logout/ | — | Sí | Sí | Sí |
| Ver la lista de usuarios y los datos de cada cuenta | ver_usuarios | /user/list/; /user/manage/ (lectura) | — | Sí | — | — |
| Crear cuentas de usuario | crear_usuarios | /user/create/ | — | Sí | — | — |
| Modificar, desactivar y reactivar cuentas | modificar_usuarios | /user/manage/ (escritura) | — | Sí | — | — |
| Asignar y quitar roles a los usuarios | asignar_roles | Campo roles de /user/create/ y /user/manage/ | — | Sí | — | — |
| Generar enlaces de activación y de restablecimiento | generar_enlaces | /user/manage/reset-link/ | — | Sí | — | — |
| Consultar la bitácora de sesiones y la bitácora de seguridad | ver_bitacoras | /user/log/, /user/events/ | — | Sí | — | — |
| Ver los roles, sus permisos y el catálogo de permisos | ver_roles | /user/roles/ (lectura), /user/permissions/ | — | Sí | — | — |
| Crear, modificar y eliminar roles | gestionar_roles | /user/roles/ (escritura) | — | Sí | — | — |
| Crear, modificar y eliminar equipos, marcas y categorías | gestionar_inventario | /item/items/, /item/brands/, /item/categories/ | — | — | Sí | — |
| Registrar préstamos, y consultar y cerrar los propios | registrar_prestamos | /loan/loan/ | — | — | Sí | Sí |
| Ver y cerrar los préstamos de todos los usuarios | ver_todos_prestamos | /loan/loan/ (amplía la consulta a todos los préstamos) | — | — | Sí | — |

Reglas que acompañan la matriz:

- Ninguna fila de seguridad comparte un rol con una de laboratorio: un rol no combina permisos de las dos áreas, y una cuenta no tiene roles de las dos áreas (D18).
- El rol de administrador de seguridad está protegido: siempre tiene todos los permisos de seguridad y no se modifica ni se elimina (D27). Los roles de laboratorio se pueden cambiar desde la aplicación, y la matriz de la pantalla "Roles" refleja esos cambios.
- La verificación de estado (/health_check) y la documentación de la API (/api/docs/, /api/schema/) son públicas y no devuelven datos del sistema.
- Las pruebas automáticas verifican la matriz: toda ruta declara un permiso del catálogo o es una de las públicas de esta tabla, y los roles por defecto tienen exactamente los permisos marcados (user/tests/test_rbac.py).

### 8.4 Contraseñas

| N.º | Deficiencia encontrada | Corrección | Se demuestra en | OWASP | Estado |
| --- | --- | --- | --- | --- | --- |
| D20 | Al cambiar una contraseña no se valida la política (UserSerializer.update en user/serializers.py) | Validar la política en toda creación y cambio de contraseña, respondiendo 400 con los requisitos que no se cumplen | 9.3 | A07 | Implementado |
| D21 | Las contraseñas no vencen | Vencimiento a los 90 días. El usuario la renueva por su cuenta, sin intervención del administrador: inicia sesión con la contraseña vencida y el sistema le exige cambiarla antes de cualquier otra acción, ingresando la actual y una nueva. Mientras no la cambie, el servidor solo acepta el cambio de contraseña y el cierre de sesión, así que una aplicación modificada no puede saltarse el paso. Los 90 días se cuentan desde que el usuario eligió su contraseña, también cuando la definió con un enlace (D24, D26). Implementación: `PASSWORD_MAX_AGE_DAYS = 90` en settings.py, contados desde `password_changed_at` (D26), que se actualiza con cada contraseña elegida. El inicio de sesión responde `password_expired: true` y queda en la bitácora de seguridad. Un middleware (PasswordExpiredMiddleware) revisa cada petición, no cada vista, y mientras la contraseña esté vencida responde 403 con el código `password_expired` a todo salvo el inicio de sesión, el cierre de sesión, la verificación de estado (sin datos, la aplicación la usa para saber si hay conexión) y /user/me/; en /user/me/ solo acepta el cambio de contraseña, con la actual (D14) y respetando el historial (D22). Al cambiar la contraseña propia la sesión actual sigue abierta y se cierran las demás. En la aplicación, la pantalla "Su contraseña venció" aparece al iniciar sesión y no se puede cerrar: solo cambiarla o cerrar la sesión. La misma pantalla, como "Cambiar contraseña", se abre en cualquier momento con el botón de llave de la barra superior. Al probarlo se corrigió un error previo de la aplicación web: usaba el token CSRF anterior al inicio de sesión, así que la primera escritura tras iniciar sesión fallaba | 9.3 | A07 | Implementado |
| D22 | El historial de contraseñas está instalado pero no configurado, así que se puede reutilizar una contraseña anterior | Impedir reutilizar las últimas 5 contraseñas, en todo cambio: el propio (D14), por vencimiento (D21) y con un enlace (D24, D26). Las últimas 5 son la actual y las 4 anteriores; una más antigua sí se puede volver a usar. Se aplica hoy al cambio propio (/user/me/), al que hace el administrador de seguridad (/user/manage/) y al comando changepassword, con el mensaje "La contraseña no puede ser igual a la actual ni a las 4 anteriores."; D21, D24 y D26 lo heredan al validar con la misma política. El historial guarda solo hashes PBKDF2-SHA256 de 1 000 000 de iteraciones con una sal por usuario (el paquete no admite Argon2), con las iteraciones fijas en el código para que una actualización de Django no deje de reconocer las contraseñas anteriores | 9.3 | A07 | Implementado |
| D23 | No hay bloqueo de cuenta, solo un límite de 3 intentos por minuto que se reinicia solo | Bloquear la cuenta al tercer intento fallido; se desbloquea con un enlace de restablecimiento generado por el administrador de seguridad (D24). Implementación: se cuentan los inicios de sesión fallidos seguidos de cada cuenta (`failed_login_attempts`, en la base de datos, así que los intentos simultáneos también cuentan) y se bloquea al tercero (`locked_at`, `LOGIN_MAX_FAILED_ATTEMPTS` en settings.py); un inicio de sesión exitoso reinicia el conteo. Una cuenta bloqueada no entra ni con la contraseña correcta, y recibe exactamente la misma respuesta que un código inexistente ("Código de usuario o contraseña incorrectos"), porque un mensaje de "cuenta bloqueada" revelaría qué códigos existen (D12); la pantalla "Recuperar contraseña" explica que hay que pedir un enlace. Elegir una contraseña nueva desbloquea la cuenta: con el enlace de restablecimiento o, para un administrador de seguridad (que no recibe enlaces, D27), con `changepassword` en el servidor. La edición de la cuenta muestra al administrador de seguridad que está bloqueada. El bloqueo, los intentos sobre una cuenta bloqueada y el desbloqueo quedan en la bitácora de seguridad. Riesgo aceptado: como los códigos de usuario son predecibles (`usr.jperez`), cualquiera puede bloquear una cuenta ajena con tres intentos; lo exige la política, y el desbloqueo con un enlace lo resuelve. Las sesiones abiertas de una cuenta no se cierran al bloquearla, porque el bloqueo detiene a quien prueba contraseñas, no a quien ya inició sesión | 9.3 | A07 | Implementado |
| D24 | No se puede desbloquear una cuenta ni reiniciar una contraseña, y el botón "Recuperar contraseña" no hace nada | Si el usuario olvidó su contraseña o su cuenta está bloqueada, lo solicita al administrador de seguridad, que genera un enlace de restablecimiento de un solo uso con vencimiento de 24 horas. Al generarlo, la contraseña anterior deja de funcionar y se cierran las sesiones abiertas de la cuenta, por si estaba comprometida. El usuario abre el enlace, ve su código de usuario y elige una nueva contraseña que cumpla la política; el enlace deja de funcionar al usarse. Ninguna contraseña viaja por correo ni por otro medio, y el administrador nunca la conoce. El botón "Recuperar contraseña" indica que se debe pedir el enlace al administrador de seguridad. Implementación: modelo PasswordLink, que guarda solo el hash SHA-256 del enlace (quien lea la base de datos no puede usar los enlaces pendientes). El administrador de seguridad lo genera desde la edición de la cuenta (/user/manage/reset-link/), y la aplicación lo muestra una sola vez; generar uno nuevo anula el anterior. Para cerrar las sesiones basta con invalidar la contraseña: Django compara en cada petición un hash de la contraseña guardado en la sesión. La persona abre el enlace en la aplicación web (`?enlace=…`), que lo revisa en /user/password-link/check/ y guarda la contraseña en /user/password-link/; el enlace viaja en el cuerpo de la petición, no en la dirección de la API, para que no quede en los registros del servidor. Un enlace usado, vencido o de una cuenta desactivada recibe el mismo mensaje. No se generan enlaces para cuentas de administrador de seguridad (D27; esas cuentas se recuperan en el servidor con changepassword) ni para cuentas desactivadas. La generación y el restablecimiento quedan en la bitácora de seguridad, sin el enlace. El enlace se arma con la variable FRONTEND_URL, obligatoria en producción. El desbloqueo de cuentas se agrega con D23 | 9.3 y 10 (menos asombro) | A07 | Implementado |
| D25 | El algoritmo de hash de contraseñas no está definido ni documentado (se usa PBKDF2-SHA256 por omisión) | Argon2id, el algoritmo que recomiendan OWASP (Password Storage Cheat Sheet) y Django, ganador de la Password Hashing Competition (RFC 9106). Requiere mucha memoria en cada intento (100 MiB, 2 pasadas, paralelismo 8, los valores de Django, superiores al mínimo de OWASP), lo que encarece los ataques con GPU o hardware dedicado. Definido en `PASSWORD_HASHERS` (settings.py) como el único algoritmo aceptado, y documentado en la política de contraseñas. No se mantiene PBKDF2-SHA256 para hashes anteriores: el sistema entra en producción con la base de datos vacía, así que no existen contraseñas guardadas con otro algoritmo | 9.3 | A04 | Implementado |
| D26 | No hay un procedimiento para generar ni resguardar las contraseñas de los usuarios: el administrador las escribe a mano | Las cuentas nuevas no reciben una contraseña: al crearlas, el sistema genera automáticamente un enlace de activación de un solo uso con vencimiento de 24 horas y lo muestra una sola vez al administrador de seguridad, que lo entrega a la persona. Al abrirlo, la persona ve su código de usuario y elige su contraseña. Si el enlace vence, el administrador genera otro. No se envían contraseñas por correo: quedarían legibles en la bandeja de entrada y obligarían a guardar credenciales de un servidor de correo (ver D2). La excepción es la cuenta inicial, que se crea antes de que exista la aplicación: create_initial_admin genera su contraseña al azar y la muestra una sola vez, para guardarla en un gestor de contraseñas (por ejemplo Bitwarden o KeePassXC). Implementación: /user/create/ y /user/create/admin/ responden 400 si la petición trae una contraseña, crean la cuenta sin contraseña utilizable y devuelven el enlace de activación una sola vez (sin caché), que la aplicación muestra al terminar el registro. El enlace usa el mismo mecanismo que el de restablecimiento (D24): se guarda solo su hash, vence a las 24 horas, sirve una vez y la página de la aplicación lo presenta como "Activar su cuenta". La cuenta guarda cuándo eligió su contraseña (`password_changed_at`, que usará el vencimiento de D21); mientras está vacío la cuenta está pendiente de activación, no puede iniciar sesión y la edición de la cuenta ofrece "Generar enlace de activación" en lugar del de restablecimiento. Las cuentas que ya existían al aplicar la migración se marcan como activadas. La creación, el enlace de activación y la activación quedan en la bitácora de seguridad | 9.3 | A06 | Implementado |

### 8.5 Registro de eventos y manejo de errores

| N.º | Deficiencia encontrada | Corrección | Se demuestra en | OWASP | Estado |
| --- | --- | --- | --- | --- | --- |
| D28 | Solo se registran el inicio y el cierre de sesión: los intentos fallidos, los bloqueos, los desbloqueos y los cambios de roles y permisos no dejan rastro | Registrar estos eventos de seguridad con fecha, usuario y acción, consultables por el administrador de seguridad. Bitácora de seguridad en una tabla propia, separada de la bitácora de sesiones, que solo crece: los eventos no se pueden modificar ni eliminar, ni desde la API ni desde el código, así que quien actúa no puede borrar su rastro. Cada evento guarda fecha, tipo, quién actuó, la cuenta afectada, la IP y el detalle (por ejemplo, qué campos cambiaron y sus valores anteriores y nuevos). Se registran hoy: inicio y cierre de sesión, inicio de sesión fallido, inicio de sesión rechazado por el límite de intentos, creación de cuentas (también la inicial), cambios hechos por el administrador (rol, estado y nombre), cambios del propio perfil y de la propia contraseña, la contraseña actual incorrecta al cambiar la contraseña propia (D14), los enlaces de restablecimiento generados y las contraseñas restablecidas con un enlace (D24), los enlaces de activación generados y las cuentas activadas (D26), los bloqueos por intentos fallidos y los desbloqueos (D23), los inicios de sesión con la contraseña vencida (D21), y toda acción rechazada por permisos. Nunca se guardan contraseñas: de un inicio de sesión fallido con un código inexistente solo se guarda el texto si tiene la forma de un código de usuario, por si alguien escribió su contraseña en ese campo. El administrador de seguridad la consulta en /user/events/ y en la pantalla "Bitácora de seguridad", filtrando por código de usuario, tipo de evento y fechas. También se registran la creación, modificación y eliminación de roles, con sus permisos anteriores y nuevos, y los roles asignados y quitados a cada cuenta (D15) | 9.2 y 9.3 | A09 | Implementado |
| D29 | Si una validación del modelo falla, por ejemplo un préstamo con la fecha de devolución anterior a la de préstamo, la API responde con error 500 en lugar de 400 y, con DEBUG activo, muestra la traza completa | Convertir los errores de validación en respuestas 400 con un mensaje claro, revertir el préstamo completo si falla, y registrar los errores inesperados sin mostrar detalles internos | 10 (fallar de forma segura) | A10 | Implementado |

## Enlaces

**Código fuente (GitHub):** https://github.com/Andrewing1000/LabLend

**Política de contraseñas:** [politica-contrasenas.md](politica-contrasenas.md)

**Sistema publicado (hosting):** [URL del sistema]

**Usuario administrador de seguridad:** [usuario]

**Contraseña del administrador de seguridad:** [contraseña]
