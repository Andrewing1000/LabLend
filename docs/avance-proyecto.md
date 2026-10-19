# Avance del proyecto — LabLend

Estado al 19 de octubre de 2026. La defensa es el martes 28 de octubre (faltan 9 días).

## 1. Trabajo pendiente

De las 31 deficiencias de la sección 8 de [proyecto-seguridad.md](proyecto-seguridad.md) están implementadas **las 31**. Roles y permisos (D15 a D19) está terminado: lo que el enunciado pide demostrar ya funciona en la aplicación (mostrar los roles, agregar uno, cambiar permisos de uno existente, eliminar uno, asignar un rol a un usuario y quitárselo), y la matriz de accesos está en el documento y en la pantalla "Roles".

El hosting y el despliegue (D7, D8) quedaron terminados: el sistema está publicado en https://lablend.dontrisk.org, servido con Gunicorn detrás de HTTPS con redirección y HSTS, con la aplicación y la API en el mismo dominio —lo que permitió que la cookie de sesión sea HttpOnly, Secure y SameSite=Lax—, su base de datos de producción, sus variables de entorno y el administrador de seguridad inicial ya creado.

El trabajo que falta se reduce a dos bloques:

| N.º | Trabajo pendiente | Qué incluye | Peso en la rúbrica |
| --- | --- | --- | --- |
| 1 | **Documento: capturas y PDF** | Las secciones 9 (usuarios, roles, contraseñas) y 10 (principios de diseño seguro y reglas de oro de OWASP) ya están escritas, y Enlaces tiene la URL y el usuario del administrador. Faltan las 21 capturas de pantalla que el enunciado exige, señaladas en el documento con marcadores `**Captura N**` que indican qué fotografiar; la contraseña del administrador en Enlaces; y exportar como `Proy-NombreGrupo-UA2.pdf`. También falta completar la carátula de la sección 1 (grupo, integrantes, lugar y fecha) | 15 puntos |
| 2 | **Edición del nombre propio en la aplicación** | El módulo 2 está parcial: desde la aplicación solo se cambia la contraseña propia | Menor; el enunciado no lo pide de forma explícita |

## 2. Avance por esfuerzo

El avance se mide por esfuerzo, no por cantidad de deficiencias. Las unidades son relativas: 1 equivale a una corrección pequeña y bien acotada, como D25 (algoritmo de hash). Se estimaron según lo que costó cada punto terminado.

| Área | Esfuerzo hecho | Esfuerzo pendiente |
| --- | --- | --- |
| 8.1 Configuración, secretos y despliegue (D1–D6, D9, D10) | 8 | — |
| 8.2 Usuarios y autenticación (D11–D14, D30, D31) | 7,5 | — |
| 8.3 Roles: segregación y superusuario (D18, D27) | 5 | — |
| 8.4 Contraseñas (D20–D26) | 14,5 | — |
| 8.5 Registro de eventos y manejo de errores (D28, D29) | 4,5 | — |
| Documento, secciones 1 a 8 | 4 | — |
| Roles y permisos, RBAC (D15–D17, D19) | 15,5 | — |
| Hosting y despliegue (D7, D8) | 7 | — |
| Secciones 9 y 10, y enlaces | 3 | — |
| Capturas y PDF | — | 2 |
| Edición del nombre propio | — | 0,5 |
| **Total** | **69** | **2,5** |

**Avance: alrededor del 96 %** (69 de unas 71,5 unidades).

Contando deficiencias el avance es del 100 % (31 de 31), pero lo que falta pesa más que eso: las capturas son 21 y hay que tomarlas con el sistema funcionando y con sesión abierta, así que dependen de que nada se rompa en los últimos días.

> Las 5 unidades que la versión anterior asignaba a "Secciones 9 y 10, capturas, enlaces y PDF" se repartieron en 3 por las secciones escritas y 2 por las capturas y el PDF. Ese reparto es una estimación: conviene revisarlo después de tomar las primeras capturas, cuando se sepa cuánto cuesta cada una.

## 3. Orden sugerido

1. **Las capturas, ahora.** Son el único trabajo que exige el sistema en funcionamiento y con sesión abierta, así que son lo más expuesto a un imprevisto. Cada marcador del documento dice qué fotografiar, y cinco de ellos traen el comando que produce la evidencia (el hash Argon2id en la base, la cabecera HSTS, la redirección a HTTPS y `check --deploy`).
2. **La carátula y la contraseña del administrador en Enlaces,** que son los dos datos que el documento todavía espera.
3. **El PDF al final,** una vez que las capturas estén dentro.
4. **La edición del nombre propio,** si queda tiempo: el enunciado no la pide de forma explícita.
