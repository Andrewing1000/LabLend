# OWASP Top 10:2025 — categorías usadas en LabLend

El [OWASP Top 10:2025](https://top10.owasp.org/2025) es la lista de las diez categorías de riesgo más críticas en aplicaciones web. El documento del proyecto ([proyecto-seguridad.md](proyecto-seguridad.md), sección 8) clasifica cada deficiencia encontrada en LabLend con uno de estos códigos.

Cada categoría tiene su nombre en español, el nombre original en inglés entre paréntesis, su descripción en español y luego en inglés, las deficiencias de LabLend que le corresponden y un ejemplo tomado del sistema.

## Resumen

| Código | Nombre | Nombre original (inglés) | Deficiencias en LabLend |
| --- | --- | --- | --- |
| A01 | Control de acceso roto | Broken Access Control | D6, D13, D15, D16, D17, D18, D19, D27 |
| A02 | Configuración de seguridad incorrecta | Security Misconfiguration | D2, D5, D7, D9 |
| A03 | Fallas en la cadena de suministro de software | Software Supply Chain Failures | D10 |
| A04 | Fallas criptográficas | Cryptographic Failures | D1, D8, D25 |
| A05 | Inyección | Injection | Ninguna |
| A06 | Diseño inseguro | Insecure Design | D26, D31 |
| A07 | Fallas de autenticación | Authentication Failures | D3, D4, D12, D14, D20, D21, D22, D23, D24, D30 |
| A08 | Fallas de integridad del software o de los datos | Software or Data Integrity Failures | Ninguna |
| A09 | Fallas en el registro y las alertas de seguridad | Security Logging and Alerting Failures | D28 |
| A10 | Manejo incorrecto de condiciones excepcionales | Mishandling of Exceptional Conditions | D29 |

D11 (código de usuario) no tiene categoría OWASP: es un requisito del curso.

## A01 — Control de acceso roto (Broken Access Control)

**Español:** Un usuario puede ver o hacer algo que no le corresponde según su rol: acceder a funciones de administración, modificar cuentas ajenas o ver datos de otros. Ocurre cuando el servidor no verifica los permisos en cada petición, o cuando los verifica de forma inconsistente.

**Inglés:** A user can see or do something their role should not allow: reach admin functions, modify other people's accounts or read others' data. It happens when the server does not check permissions on every request, or checks them inconsistently.

**Deficiencias:** D6, D13, D15, D16, D17, D18, D19, D27.

**Ejemplo en LabLend:** un administrador de laboratorio puede cambiar la contraseña de cualquier cuenta, incluida la del superadministrador (D13).

## A02 — Configuración de seguridad incorrecta (Security Misconfiguration)

**Español:** El sistema queda expuesto por cómo está configurado, no por un error en el código: modo de depuración activo en producción, credenciales de ejemplo, cookies sin protecciones o paneles de administración accesibles.

**Inglés:** The system is exposed by how it is configured rather than by a bug in the code: debug mode on in production, sample credentials, unprotected cookies or reachable admin panels.

**Deficiencias:** D2, D5, D7, D9.

**Ejemplo en LabLend:** con DEBUG=True, ante un error el servidor mostraba el código, la configuración y las rutas (D5).

## A03 — Fallas en la cadena de suministro de software (Software Supply Chain Failures)

**Español:** El sistema depende de librerías, frameworks o herramientas sin soporte, con vulnerabilidades conocidas o de origen no confiable.

**Inglés:** The system depends on libraries, frameworks or tools that are unsupported, have known vulnerabilities or come from untrusted sources.

**Deficiencias:** D10.

**Ejemplo en LabLend:** Django 3.2 y Pillow 8.2 ya no recibían parches de seguridad (D10).

## A04 — Fallas criptográficas (Cryptographic Failures)

**Español:** Los datos sensibles no están protegidos como corresponde: claves secretas expuestas, información que viaja sin cifrar o algoritmos de cifrado y hash débiles o sin definir.

**Inglés:** Sensitive data is not properly protected: exposed secret keys, data sent unencrypted, or weak or undefined encryption and hashing algorithms.

**Deficiencias:** D1, D8, D25.

**Ejemplo en LabLend:** la clave secreta de Django estaba escrita en settings.py y publicada en GitHub (D1).

## A05 — Inyección (Injection)

**Español:** Datos enviados por el usuario se interpretan como parte de un comando o consulta, por ejemplo SQL, y permiten leer o modificar información sin autorización.

**Inglés:** User-supplied data is interpreted as part of a command or query, such as SQL, allowing unauthorized reading or modification of data.

**Deficiencias:** ninguna. LabLend no usa SQL directo: todas las consultas pasan por el ORM de Django, que trata los datos del usuario como parámetros.

## A06 — Diseño inseguro (Insecure Design)

**Español:** El problema está en cómo se pensó una función o un proceso, no en cómo se programó: aunque el código funcione como se diseñó, el diseño mismo deja un riesgo.

**Inglés:** The problem lies in how a feature or process was designed, not in how it was coded: even when the code works as designed, the design itself leaves a risk.

**Deficiencias:** D26, D31.

**Ejemplo en LabLend:** la pantalla de login mostraba un botón de Google que no autenticaba y solo abría la página de Google (D31).

## A07 — Fallas de autenticación (Authentication Failures)

**Español:** El sistema no verifica bien la identidad de quien ingresa: contraseñas débiles o reutilizables, cuentas sin bloqueo ante intentos repetidos, credenciales predefinidas o mensajes que revelan qué usuarios existen.

**Inglés:** The system does not properly verify who is logging in: weak or reusable passwords, no lockout after repeated attempts, built-in credentials or messages that reveal which users exist.

**Deficiencias:** D3, D4, D12, D14, D20, D21, D22, D23, D24, D30.

**Ejemplo en LabLend:** el login respondía distinto si el correo no existía o si la contraseña era incorrecta, lo que permitía averiguar qué cuentas estaban registradas (D12).

## A08 — Fallas de integridad del software o de los datos (Software or Data Integrity Failures)

**Español:** El sistema acepta código, actualizaciones o datos sin verificar que no hayan sido alterados.

**Inglés:** The system accepts code, updates or data without verifying that they have not been tampered with.

**Deficiencias:** ninguna.

## A09 — Fallas en el registro y las alertas de seguridad (Security Logging and Alerting Failures)

**Español:** Los eventos importantes, como intentos fallidos de ingreso o cambios de permisos, no quedan registrados o nadie es alertado, así que un ataque puede pasar desapercibido.

**Inglés:** Important events, such as failed logins or permission changes, are not logged or nobody is alerted, so an attack can go unnoticed.

**Deficiencias:** D28.

**Ejemplo en LabLend:** solo se registran el inicio y el cierre de sesión; los intentos fallidos y los cambios de roles no dejan rastro (D28).

## A10 — Manejo incorrecto de condiciones excepcionales (Mishandling of Exceptional Conditions)

**Español:** Ante un error o una situación inesperada, el sistema falla de forma insegura: muestra detalles internos, queda en un estado inconsistente o deja pasar lo que debería rechazar.

**Inglés:** When an error or unexpected situation occurs, the system fails unsafely: it shows internal details, ends up in an inconsistent state or lets through what it should reject.

**Deficiencias:** D29.

**Ejemplo en LabLend:** un préstamo con la fecha de devolución anterior a la de préstamo provocaba un error 500 con la traza completa, en lugar de un error 400 con un mensaje claro (D29).
