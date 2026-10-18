# Política de contraseñas de LabLend

Este documento describe las reglas que debe cumplir toda contraseña del sistema, dónde se aplican y cómo se protegen. La política está configurada en `AUTH_PASSWORD_VALIDATORS` (`backend/app/app/settings.py`) y se valida en el servidor: la aplicación Flutter no puede saltársela.

## 1. Reglas

Una contraseña es válida solo si cumple **todas** estas reglas:

| Regla | Requisito | Mensaje si no se cumple |
| --- | --- | --- |
| Letras | Al menos 12 letras | La contraseña debe tener al menos 12 letras. |
| Mayúsculas | Al menos 1 letra mayúscula | La contraseña debe tener al menos 1 mayúscula. |
| Minúsculas | Al menos 1 letra minúscula | La contraseña debe tener al menos 1 minúscula. |
| Dígitos | Al menos 1 dígito | La contraseña debe tener al menos 1 dígito. |
| Caracteres especiales | Al menos 1 de estos: `~ ! @ # $ % ^ & * ( ) _ + { } " : ; ' [ ]` | La contraseña debe tener al menos 1 caracter especial. |
| No es común | No puede estar en la lista de unas 20 000 contraseñas comunes de Django | Esta contraseña es demasiado común. |
| No es solo numérica | No puede tener solo dígitos | Esta contraseña es completamente numérica. |
| No se parece a los datos del usuario | No puede ser demasiado parecida al código de usuario ni al correo | La contraseña es demasiado similar a la de email. |
| Longitud | Al menos 12 caracteres | Asegúrese de que este campo tenga al menos 12 caracteres. |
| Historial | No puede ser igual a la contraseña actual ni a las 4 anteriores de la cuenta, es decir, a ninguna de las últimas 5. Una contraseña más antigua sí se puede volver a usar | La contraseña no puede ser igual a la actual ni a las 4 anteriores. |

**Longitud mínima real: 14 caracteres.** Las 12 letras, más un dígito y un caracter especial, suman al menos 14. La regla de longitud (12 caracteres) y el mínimo de 8 caracteres de Django nunca son las que deciden.

**Ejemplo válido:** `Laboratorio#2026Ucb` (14 letras, mayúsculas, minúsculas, un dígito y `#`).

| Ejemplo inválido | Regla que incumple |
| --- | --- |
| `laboratorio#2026ucb` | No tiene mayúsculas |
| `Laboratorio2026Ucb` | No tiene caracter especial |
| `Laboratorio-2026-Ucb` | `-` no cuenta como caracter especial |
| `Laborator#2026Uc` | Tiene 11 letras |
| `Password1234` | Es común, tiene menos de 12 letras y no tiene caracter especial |

> **Limitación conocida:** solo cuentan como especiales los símbolos de la lista. Otros comunes, como `-`, `.`, `?`, `/`, `=` o el espacio, no cuentan, aunque la contraseña los tenga. Ampliar la lista está previsto en la gestión de contraseñas (módulo 5).

## 2. Dónde se aplica

| Situación | Endpoint o comando | Resultado si la contraseña no cumple |
| --- | --- | --- |
| Crear un asistente o un administrador | `/user/create/`, `/user/create/admin/` | 400 con las reglas incumplidas; la cuenta no se crea |
| Cambiar la contraseña propia | `/user/me/`, con la contraseña actual en `current_password` (D14) | 400 con las reglas incumplidas; se mantiene la contraseña anterior. Si falta la contraseña actual o es incorrecta, 400 en `current_password`, antes de revisar la política |
| Elegir una contraseña nueva con un enlace de restablecimiento (D24) | `/user/password-link/` | 400 con las reglas incumplidas; el enlace sigue sirviendo hasta que se use o venza |
| Crear la cuenta inicial | `python manage.py create_initial_admin` | La contraseña la genera el sistema al azar (24 caracteres) y siempre cumple la política |
| Recuperar la contraseña del administrador desde el servidor | `python manage.py changepassword` | El comando rechaza la contraseña y la vuelve a pedir |

El administrador de seguridad no escribe la contraseña de ninguna cuenta existente: `/user/manage/` responde 400 si la petición trae una contraseña, y en su lugar se genera un enlace de restablecimiento (sección 5).

El historial se aplica en todos los cambios de esta tabla, también con un enlace de restablecimiento. Los cambios que se agreguen con el módulo 5 (vencimiento y enlaces de activación) deben validar la contraseña con la cuenta (`validate_password(contraseña, user=cuenta)`) para que el historial los cubra.

La respuesta 400 indica las reglas incumplidas en el campo `password`. Si la contraseña tiene menos de 12 caracteres, solo se informa la longitud. Con 12 o más, se informan todas las demás reglas incumplidas a la vez, para que el usuario pueda corregirlas en un solo intento.

## 3. Almacenamiento

Las contraseñas nunca se guardan en texto plano. Django guarda solo su hash con **Argon2id** (D25), con una sal aleatoria distinta para cada contraseña. La configuración está en `PASSWORD_HASHERS` (`backend/app/app/settings.py`).

| Parámetro | Valor | Motivo |
| --- | --- | --- |
| Algoritmo | Argon2id | Primera opción de OWASP (Password Storage Cheat Sheet) y algoritmo recomendado por Django; ganador de la Password Hashing Competition, estandarizado en RFC 9106 |
| Memoria | 100 MiB por hash | Cada intento ocupa esa memoria, lo que encarece los ataques con GPU o hardware dedicado (OWASP pide al menos 19 MiB) |
| Pasadas | 2 | Valor de Django, igual al de OWASP |
| Paralelismo | 8 | Valor de Django |

Calcular un hash tarda unos 100 ms, lo que no se nota al iniciar sesión pero limita los intentos de quien robe la base de datos.

**Historial (D22):** para comparar una contraseña nueva con las anteriores, el historial guarda un hash de cada una de las últimas 5 contraseñas de la cuenta, incluida la actual; las más antiguas se borran. Usa **PBKDF2-SHA256 con 1 000 000 de iteraciones** (el valor de Django, por encima de las 600 000 que pide OWASP) y una sal aleatoria por usuario, definido en `DPV_DEFAULT_HISTORY_HASHER` (`backend/app/core/passwords.py`). No usa Argon2id porque el paquete del historial compara hashes con un número de iteraciones guardado, que Argon2 no tiene. Las iteraciones están fijas en el código, para que una actualización de Django no las cambie y deje de reconocer las contraseñas anteriores. Calcular cada hash tarda unos 0,4 segundos, así que cambiar una contraseña tarda cerca de un segundo.

**Único algoritmo aceptado:** antes de D25 se usaba PBKDF2-SHA256, el algoritmo por omisión de Django. No se mantiene para verificar hashes anteriores, porque el sistema entra en producción con la base de datos vacía. Un hash guardado con otro algoritmo no se acepta, aunque la contraseña sea correcta.

Nadie puede ver la contraseña de una cuenta, tampoco los administradores. Por eso la contraseña de la cuenta inicial se muestra una sola vez y debe guardarse en el gestor de contraseñas.

## 4. Protección del inicio de sesión

| Medida | Estado |
| --- | --- |
| Límite de 3 intentos de inicio de sesión por minuto por código de usuario, exista o no (respuesta 429) | Implementado |
| El inicio de sesión solo se acepta en `/user/token/`, que aplica el límite; la API rechaza credenciales enviadas por HTTP Basic en otros endpoints (D30) | Implementado |
| La sesión expira a los 15 minutos | Implementado |
| Mensaje genérico que no revela si la cuenta existe (D12) | Implementado |
| Cambiar la contraseña propia exige la contraseña actual, con un límite de 3 intentos por minuto por usuario (respuesta 429); un intento con la contraseña actual incorrecta queda en la bitácora de seguridad. El correo de una cuenta no se puede cambiar. Así una sesión robada no basta para tomar la cuenta, ni para adivinar la contraseña fuera del límite del login (D14) | Implementado |

## 5. Contraseña olvidada: enlaces de restablecimiento (D24)

Ninguna contraseña viaja por correo ni por otro medio, y el administrador nunca la conoce. Si una persona olvidó su contraseña, se la pide al administrador de seguridad, que genera un enlace de restablecimiento:

1. En la aplicación, el administrador de seguridad abre la cuenta en la gestión de usuarios y pulsa **Generar enlace de restablecimiento** (`/user/manage/reset-link/`). En ese momento la contraseña actual deja de funcionar y se cierran las sesiones abiertas de la cuenta, por si estaba comprometida; un enlace anterior sin usar también deja de funcionar.
2. La aplicación muestra el enlace **una sola vez**: el servidor guarda solo un hash SHA-256 del enlace, así que no puede volver a mostrarlo, y quien lea la base de datos no puede usar los enlaces pendientes. El administrador lo entrega a la persona.
3. La persona abre el enlace en el navegador. La aplicación web muestra su código de usuario y le pide la contraseña nueva dos veces (`/user/password-link/check/` y `/user/password-link/`). La contraseña debe cumplir la política, historial incluido.
4. El enlace deja de funcionar al usarse, a las 24 horas o si la cuenta se desactiva. En esos casos la página dice "El enlace no es válido o venció. Pida uno nuevo al administrador de seguridad.", sin distinguir el motivo.

No se generan enlaces para cuentas de administrador de seguridad (D27) ni para cuentas desactivadas. Un administrador de seguridad que olvidó su contraseña la recupera en el servidor con `python manage.py changepassword` (ver README).

La generación del enlace y la contraseña restablecida quedan en la bitácora de seguridad, sin el enlace. El enlace usa la dirección de la aplicación web definida en `FRONTEND_URL` (ver README). El botón "Recuperar contraseña" de la pantalla de inicio de sesión explica que se debe pedir el enlace al administrador de seguridad.

## 6. Pendiente (módulo 5, gestión de contraseñas)

Cada situación que falta tiene su propio camino:

| Situación | Quién la resuelve | Cómo |
| --- | --- | --- |
| Cuenta nueva (D26) | Automático | Al crear la cuenta, el sistema genera un enlace de activación de un solo uso (24 horas) y lo muestra una vez al administrador de seguridad, que lo entrega a la persona; ella elige su contraseña. La cuenta inicial es la excepción: `create_initial_admin` genera su contraseña y la muestra una vez |
| Contraseña vencida, a los 90 días (D21) | El propio usuario | Inicia sesión con la contraseña vencida y debe cambiarla, ingresando la actual y una nueva, antes de cualquier otra acción |
| Cuenta bloqueada al tercer intento fallido (D23) | El administrador de seguridad, a pedido | El mismo enlace de restablecimiento (sección 5) la desbloquea |

Además:

- Ampliar la lista de caracteres especiales.

## 7. Verificación

Las pruebas de `backend/app/user/tests/test_password_policy.py` comprueban cada regla por separado: cada contraseña de prueba incumple una sola regla y debe rechazarse solo por ella. También comprueban el límite de 11 y 12 letras, los símbolos que no cuentan como especiales y la creación de cuentas con contraseñas débiles. Si una regla se quitara de la configuración, su prueba fallaría.

Las pruebas de `backend/app/user/tests/test_password_hashing.py` comprueban que una contraseña nueva se guarda con Argon2id y que no se acepta un hash de otro algoritmo (PBKDF2), aunque la contraseña sea correcta.

Las pruebas de `backend/app/user/tests/test_password_history.py` comprueban que se rechazan la contraseña actual y cada una de las 4 anteriores, que la sexta más reciente se acepta de nuevo, que el historial se aplica al cambio propio, al restablecimiento con un enlace y al comando `changepassword`, y que guarda como máximo 5 hashes por cuenta, nunca la contraseña.

Las pruebas de `backend/app/user/tests/test_current_password.py` comprueban que la contraseña propia no cambia sin la contraseña actual o con una incorrecta, que el intento incorrecto queda registrado, que la contraseña actual se verifica antes que la política, que el nombre se cambia sin ella, que el cuarto intento en un minuto recibe 429 y que ni el usuario ni el administrador de seguridad pueden cambiar el correo.

Las pruebas de `backend/app/user/tests/test_reset_link.py` comprueban que solo el administrador de seguridad genera enlaces, que no se generan para administradores de seguridad ni cuentas desactivadas, que al generarlo la contraseña anterior deja de funcionar y se cierran las sesiones, que la base de datos y la bitácora no guardan el enlace, que un enlace nuevo anula el anterior, y que el enlace muestra el código de usuario, exige la política, sirve una sola vez y deja de funcionar al vencer o si la cuenta se desactiva. `test_password_policy.py` comprueba que `/user/manage/` rechaza cualquier contraseña.
