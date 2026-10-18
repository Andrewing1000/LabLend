import 'Permissions.dart';
import 'PasswordLink.dart';
import 'SecurityEvent.dart';
import 'Session.dart';
import 'User.dart';
import 'package:dio/dio.dart';

class UserManager {
  static var manager = SessionManager();
  var requestHandler = SessionManager.httpHandler;


  Future<List<User>> getUserList(
      {String? role, bool? isActive, String? email}) async {
    if (!await isReady()) {
      return [];
    }
    if (!allowed(AppPermission.verUsuarios)) {
      return [];
    }
    if (!await sessionCheck()) {
      return [];
    }

    var response;
    try {
      Map<String, dynamic> queryParams = {};
      if (role != null) {
        queryParams['role'] = role;
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive.toString();
      }
      if (email != null && email.isNotEmpty) {
        queryParams['email'] = email;
      }

      String queryString = Uri(queryParameters: queryParams).query;
      response = await requestHandler.getRequest('/user/list/?$queryString');
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      return [];
    }

    List<User> userList = [];
    for (var userData in response.data) {
      var user = User.fromJson(userData);
      userList.add(user);
    }

    return userList;
  }

  Future<User?> getUser(String email) async {
    if (!await isReady()) {
      return null;
    }
    if (!await sessionCheck()) {
      return null;
    }

    final session = SessionManager().session;
    if (session.user.email == email) {
      var response = await requestHandler.getRequest('/user/me');
      return User.fromJson(response.data);
    }

    if (!allowed(AppPermission.verUsuarios)) {
      return null;
    }

    try {
      var response = await requestHandler
          .getRequest('/user/manage', query: {'email': email});
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        manager.errorNotification(
            error: 'No se encontró a un usuario con ese email');
      } else {
        manager.errorNotification(error: '', details: e.response?.data);
      }
      return null;
    }
  }

  /// Crea la cuenta sin contraseña (D26) y devuelve su enlace de
  /// activación, que el servidor muestra una sola vez, o null.
  Future<PasswordLink?> createUser(User user) async {
    if (!await isReady()) {
      return null;
    }
    if (!allowed(AppPermission.crearUsuarios)) {
      return null;
    }
    if (!await sessionCheck()) {
      return null;
    }

    try {
      var response =
          await requestHandler.postRequest('/user/create/',
              body: user.toJson());
      user.updateData(newUser: User.fromJson(response.data));
      return PasswordLink.fromJson(
          response.data['username'], response.data['activation_link']);
    } on DioException catch (e) {
      manager.errorNotification(
          error: 'Adición de usuario fallida', details: e.response?.data);
      return null;
    }
  }

  /// El administrador ya no escribe contraseñas de otras cuentas (D14):
  /// para eso genera un enlace de restablecimiento (createPasswordLink).
  Future<User?> updateUser(User user, {required User newUser}) async {
    if (!await isReady()) {
      return null;
    }
    if (!allowed(AppPermission.modificarUsuarios)) {
      return null;
    }
    if (!await sessionCheck()) {
      return null;
    }

    var data = newUser.toJson();

    try {
      final response = await requestHandler.patchRequest('/user/manage/',
          body: data, query: {'email': user.email});
      // La cuenta tal como quedó en el servidor, con sus permisos nuevos.
      final updated = User.fromJson(response.data);
      user.updateData(newUser: updated);
      manager.notification(notification: 'Información de usuario actualizada');
      return updated;
    } on DioException catch (e) {
      manager.errorNotification(
          error: 'Actualización fallida', details: e.response?.data);
      return null;
    }
  }

  /// Genera un enlace para la cuenta: de activación si aún no eligió su
  /// contraseña (D26), de restablecimiento si ya la tiene (D24). El
  /// servidor lo muestra una sola vez. Devuelve null si falla.
  Future<PasswordLink?> createPasswordLink(User user) async {
    if (!await isReady()) {
      return null;
    }
    if (!allowed(AppPermission.generarEnlaces)) {
      return null;
    }
    if (!await sessionCheck()) {
      return null;
    }

    try {
      var response = await requestHandler.postRequest(
          '/user/manage/reset-link/', body: {'email': user.email});
      return PasswordLink.fromJson(response.data['username'], response.data);
    } on DioException catch (e) {
      manager.errorNotification(
          error: 'No se pudo generar el enlace', details: e.response?.data);
      return null;
    }
  }

  /// Revisa un enlace de activación o restablecimiento. Devuelve el código
  /// de usuario de la cuenta y el tipo de enlace (sin la dirección), o null
  /// si el enlace no es válido o venció.
  Future<PasswordLink?> checkPasswordLink(String token) async {
    try {
      var response = await requestHandler
          .postRequest('/user/password-link/check/', body: {'token': token});
      return PasswordLink(
          username: response.data['username'],
          url: '',
          purpose: response.data['purpose']);
    } on DioException catch (e) {
      manager.errorNotification(
          error: 'Enlace no válido', details: e.response?.data);
      return null;
    }
  }

  /// Guarda la contraseña elegida con un enlace de restablecimiento.
  Future<bool> usePasswordLink(String token, String password) async {
    try {
      await requestHandler.postRequest('/user/password-link/',
          body: {'token': token, 'password': password});
      return true;
    } on DioException catch (e) {
      manager.errorNotification(
          error: 'No se pudo guardar la contraseña',
          details: e.response?.data);
      return false;
    }
  }

  Future<bool> disableUser(User user) async {
    if (!await isReady()) {
      return false;
    }
    if (!allowed(AppPermission.modificarUsuarios)) {
      return false;
    }
    if (!await sessionCheck()) {
      return false;
    }

    User newUser = user.clone();
    newUser.isActive = false;
    var result = await updateUser(user, newUser: newUser);
    return result != null;
  }

  Future<bool> enableUser(User user) async {
    if (!await isReady()) {
      return false;
    }
    if (!allowed(AppPermission.modificarUsuarios)) {
      return false;
    }
    if (!await sessionCheck()) {
      return false;
    }

    User newUser = user.clone();
    newUser.isActive = true;
    var result = await updateUser(user, newUser: newUser);
    return result != null;
  }

  /// Bitácora de seguridad (D28): los eventos más recientes primero.
  Future<List<SecurityEvent>> getSecurityEvents(
      {String? username, String? eventType}) async {
    if (!await isReady()) {
      return [];
    }
    if (!allowed(AppPermission.verBitacoras)) {
      return [];
    }
    if (!await sessionCheck()) {
      return [];
    }

    Map<String, dynamic> query = {'limit': '200'};
    if (username != null && username.trim().isNotEmpty) {
      query['usuario'] = username.trim().toLowerCase();
    }
    if (eventType != null) {
      query['tipo'] = eventType;
    }

    try {
      var response =
          await requestHandler.getRequest('/user/events/', query: query);
      return [
        for (var data in response.data['results']) SecurityEvent.fromJson(data)
      ];
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      return [];
    }
  }

  /// Cada operación pide el permiso de su función (D17).
  bool allowed(String permission) {
    return SessionManager().session.allowed(permission);
  }

  Future<bool> isReady() async {
    var session = SessionManager().session;
    return await session.isReady();
  }

  Future<bool> sessionCheck() async {
    final session = SessionManager().session;
    return await session.sessionCheck();
  }
}
