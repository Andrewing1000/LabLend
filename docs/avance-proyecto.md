# Avance del proyecto — LabLend

Estado al 18 de octubre de 2026. La defensa es el martes 28 de octubre (faltan 10 días).

## 1. Trabajo pendiente

De las 31 deficiencias de la sección 8 de [proyecto-seguridad.md](proyecto-seguridad.md) están implementadas 28. El trabajo que falta se agrupa en cuatro bloques:

| N.º | Trabajo pendiente | Qué incluye | Peso en la rúbrica |
| --- | --- | --- | --- |
| 1 | **Roles y permisos (RBAC): D19** | Ya están hechos los roles en la base de datos con permisos por función y varios roles por usuario, con sus pantallas (D15), el mecanismo único de permisos (D16) y el menú armado con los permisos del usuario (D17). Lo que el enunciado pide demostrar ya funciona en la aplicación: mostrar los roles, agregar uno, cambiar permisos de uno existente, eliminar uno, asignar un rol a un usuario y quitárselo. Falta: la matriz de accesos en una plantilla y demostrada en el sistema | Parte central de los 40 puntos de funcionalidad |
| 2 | **Hosting y despliegue: D7, D8** | Hosting gratuito, servidor de producción (Gunicorn) con HTTPS y HSTS. La aplicación y la API en el mismo dominio, para que la cookie de sesión sea HttpOnly y SameSite=Lax. Base de datos de producción, variables de entorno y administrador de seguridad inicial | El enunciado exige el sistema funcionando en el hosting, con el usuario y la contraseña del administrador de seguridad en el documento |
| 3 | **Documento: secciones 9 y 10, Enlaces y PDF** | La sección 9 (usuarios, roles, contraseñas) y la sección 10 (principios de diseño seguro y reglas de oro de OWASP) aún no existen. Capturas de pantalla de cada punto de la reingeniería, que el enunciado exige. URL del hosting y credenciales del administrador. Exportar como `Proy-NombreGrupo-UA2.pdf` | 15 puntos |
| 4 | **Edición del nombre propio en la aplicación** | El módulo 2 está parcial: desde la aplicación solo se cambia la contraseña propia | Menor; el enunciado no lo pide de forma explícita |

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
| Roles y permisos, RBAC (D15–D17, D19) | 13,5 | 2 |
| Hosting y despliegue (D7, D8) | — | 7 |
| Secciones 9 y 10, capturas, enlaces y PDF | — | 5 |
| Edición del nombre propio | — | 0,5 |
| **Total** | **57** | **14,5** |

**Avance: alrededor del 80 %** (57 de unas 71,5 unidades).

Contando deficiencias el avance sería del 90 % (28 de 31), pero lo que falta pesa más que eso: sobre todo el hosting, además de la matriz de accesos y el documento. El hosting es la estimación más incierta, porque suele traer imprevistos.

## 3. Orden sugerido

1. **Hosting ahora.** RBAC ya está hecho salvo la matriz de accesos (D19). Servir la aplicación y la API en un solo dominio con HTTPS puede obligar a cambios en el cliente Flutter, y conviene descubrirlos antes de los últimos días.
2. **Matriz de accesos (D19),** en paralelo: sale del catálogo de permisos y de los roles por defecto, y se puede verificar en la pantalla "Roles".
3. **Secciones 9 y 10, y capturas al final,** tomadas del sistema en el hosting cuando todo esté terminado, para hacerlas una sola vez.
