/// Permisos que devuelve el servidor (backend/app/core/rbac.py). La
/// aplicación muestra cada opción según estos permisos, no según el nombre
/// del rol (D17): así coincide con lo que el servidor acepta, también con
/// roles creados desde la aplicación.
class AppPermission {
  static const verUsuarios = 'ver_usuarios';
  static const crearUsuarios = 'crear_usuarios';
  static const modificarUsuarios = 'modificar_usuarios';
  static const asignarRoles = 'asignar_roles';
  static const generarEnlaces = 'generar_enlaces';
  static const verBitacoras = 'ver_bitacoras';
  static const verRoles = 'ver_roles';
  static const gestionarRoles = 'gestionar_roles';
  static const gestionarInventario = 'gestionar_inventario';
  static const registrarPrestamos = 'registrar_prestamos';
  static const verTodosPrestamos = 'ver_todos_prestamos';
}
