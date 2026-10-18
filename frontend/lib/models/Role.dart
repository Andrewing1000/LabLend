import 'package:dio/dio.dart';

import 'Permissions.dart';
import 'Session.dart';

/// Áreas de los permisos (backend/app/core/rbac.py). Un rol no mezcla
/// permisos de seguridad y de laboratorio, y una cuenta no tiene roles de
/// las dos áreas (D18).
const String securityArea = 'seguridad';
const String labArea = 'laboratorio';

const Map<String, String> areaNames = {
  securityArea: 'Seguridad',
  labArea: 'Laboratorio',
};

/// Un permiso del catálogo: una función del sistema (D15).
class PermissionInfo {
  final String codename;
  final String name;
  final String area;

  const PermissionInfo(
      {required this.codename, required this.name, required this.area});

  factory PermissionInfo.fromJson(Map<String, dynamic> data) {
    return PermissionInfo(
      codename: data['codename'],
      name: data['name'] ?? data['codename'],
      area: data['area'] ?? '',
    );
  }
}

/// Rol guardado en el servidor, con sus permisos (D15).
class Role {
  final int? id;
  String name;
  String description;
  List<String> permissions;
  /// Área de sus permisos, o null si no tiene ninguno.
  final String? area;
  /// El rol de administrador de seguridad: no se modifica ni se elimina
  /// (D27).
  final bool protected;
  final int userCount;

  Role({
    this.id,
    required this.name,
    this.description = '',
    List<String>? permissions,
    this.area,
    this.protected = false,
    this.userCount = 0,
  }) : permissions = permissions ?? [];

  bool get isSecurity => area == securityArea;

  factory Role.fromJson(Map<String, dynamic> data) {
    return Role(
      id: data['id'],
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      permissions: List<String>.from(data['permissions'] ?? const []),
      area: data['area'],
      protected: data['protected'] ?? false,
      userCount: data['user_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'permissions': permissions,
    };
  }
}

/// Gestión de roles desde la aplicación (D15): /user/roles/ y el catálogo
/// de permisos en /user/permissions/.
class RoleService {
  static final manager = SessionManager();
  final requestHandler = SessionManager.httpHandler;

  bool allowed(String permission) {
    return SessionManager().session.allowed(permission);
  }

  Future<bool> _ready() async {
    final session = SessionManager().session;
    return await session.isReady() && await session.sessionCheck();
  }

  Future<List<Role>> getRoles() async {
    if (!allowed(AppPermission.verRoles) || !await _ready()) return [];
    try {
      final response = await requestHandler.getRequest('/user/roles/');
      return [for (final data in response.data) Role.fromJson(data)];
    } on DioException catch (e) {
      manager.errorNotification(
          error: 'No se pudieron cargar los roles', details: _errors(e));
      return [];
    }
  }

  Future<List<PermissionInfo>> getPermissions() async {
    if (!allowed(AppPermission.verRoles) || !await _ready()) return [];
    try {
      final response = await requestHandler.getRequest('/user/permissions/');
      return [
        for (final data in response.data) PermissionInfo.fromJson(data)
      ];
    } on DioException catch (e) {
      manager.errorNotification(
          error: 'No se pudo cargar el catálogo de permisos',
          details: _errors(e));
      return [];
    }
  }

  Future<Role?> createRole(Role role) async {
    if (!allowed(AppPermission.gestionarRoles) || !await _ready()) {
      return null;
    }
    try {
      final response = await requestHandler.postRequest('/user/roles/',
          body: role.toJson());
      manager.notification(notification: 'Rol creado');
      return Role.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(
          error: 'No se pudo crear el rol', details: _errors(e));
      return null;
    }
  }

  Future<Role?> updateRole(Role role) async {
    if (!allowed(AppPermission.gestionarRoles) || !await _ready()) {
      return null;
    }
    try {
      final response = await requestHandler.patchRequest(
          '/user/roles/${role.id}/',
          body: role.toJson());
      manager.notification(notification: 'Rol actualizado');
      return Role.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(
          error: 'No se pudo actualizar el rol', details: _errors(e));
      return null;
    }
  }

  Future<bool> deleteRole(Role role) async {
    if (!allowed(AppPermission.gestionarRoles) || !await _ready()) {
      return false;
    }
    try {
      await requestHandler.deleteRequest('/user/roles/${role.id}/');
      manager.notification(notification: 'Rol eliminado');
      return true;
    } on DioException catch (e) {
      manager.errorNotification(
          error: 'No se pudo eliminar el rol', details: _errors(e));
      return false;
    }
  }

  /// Mensajes del servidor (400 y 403) para mostrarlos tal cual.
  Map<String, dynamic>? _errors(DioException e) {
    final data = e.response?.data;
    return data is Map<String, dynamic> ? data : null;
  }
}
