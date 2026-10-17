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
| Cambiar la contraseña propia | `/user/me/` | 400 con las reglas incumplidas; se mantiene la contraseña anterior |
| Un administrador cambia la contraseña de otra cuenta | `/user/manage/` | 400 con las reglas incumplidas; se mantiene la contraseña anterior |
| Crear la cuenta inicial | `python manage.py create_initial_admin` | La contraseña la genera el sistema al azar (24 caracteres) y siempre cumple la política |
| Recuperar la contraseña del administrador desde el servidor | `python manage.py changepassword` | El comando rechaza la contraseña y la vuelve a pedir |

El historial se aplica en todos los cambios de esta tabla, también cuando un administrador cambia la contraseña de otra cuenta. Los cambios que se agreguen con el módulo 5 (vencimiento, enlaces de restablecimiento y de activación) deben validar la contraseña con la cuenta (`validate_password(contraseña, user=cuenta)`) para que el historial los cubra.

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

## 5. Pendiente (módulo 5, gestión de contraseñas)

Ninguna contraseña se entrega por correo ni la conoce el administrador. Cada situación tiene su propio camino:

| Situación | Quién la resuelve | Cómo |
| --- | --- | --- |
| Cuenta nueva (D26) | Automático | Al crear la cuenta, el sistema genera un enlace de activación de un solo uso (24 horas) y lo muestra una vez al administrador de seguridad, que lo entrega a la persona; ella elige su contraseña. La cuenta inicial es la excepción: `create_initial_admin` genera su contraseña y la muestra una vez |
| Contraseña vencida, a los 90 días (D21) | El propio usuario | Inicia sesión con la contraseña vencida y debe cambiarla, ingresando la actual y una nueva, antes de cualquier otra acción |
| Contraseña olvidada (D24) | El administrador de seguridad, a pedido | Genera un enlace de restablecimiento de un solo uso (24 horas); la contraseña anterior deja de funcionar y se cierran las sesiones abiertas |
| Cuenta bloqueada al tercer intento fallido (D23) | El administrador de seguridad, a pedido | El mismo enlace de restablecimiento la desbloquea |

Además:

- Pedir la contraseña actual para cambiar la propia (D14).
- Ampliar la lista de caracteres especiales.

## 6. Verificación

Las pruebas de `backend/app/user/tests/test_password_policy.py` comprueban cada regla por separado: cada contraseña de prueba incumple una sola regla y debe rechazarse solo por ella. También comprueban el límite de 11 y 12 letras, los símbolos que no cuentan como especiales y la creación de cuentas con contraseñas débiles. Si una regla se quitara de la configuración, su prueba fallaría.

Las pruebas de `backend/app/user/tests/test_password_hashing.py` comprueban que una contraseña nueva se guarda con Argon2id y que no se acepta un hash de otro algoritmo (PBKDF2), aunque la contraseña sea correcta.

Las pruebas de `backend/app/user/tests/test_password_history.py` comprueban que se rechazan la contraseña actual y cada una de las 4 anteriores, que la sexta más reciente se acepta de nuevo, que el historial se aplica al cambio propio, al cambio hecho por un administrador y al comando `changepassword`, y que guarda como máximo 5 hashes por cuenta, nunca la contraseña.
