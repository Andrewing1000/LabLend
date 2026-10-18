import 'SecurityEvent.dart';
import 'Session.dart';
import 'User.dart';
import 'package:dio/dio.dart';

class UserManager {
  static var manager = SessionManager();
  var requestHandler = SessionManager.httpHandler;


  Future<List<User>> getUserList(
      {bool? isAdmin, bool? isActive, String? email}) async {
    if (!await isReady()) {
      return [];
    }
    if (!this.isAdmin()) {
      return [];
    }
    if (!await sessionCheck()) {
      return [];
    }

    var response;
    try {
      Map<String, dynamic> queryParams = {};
      if (isAdmin != null) {
        queryParams['is_admin'] = isAdmin.toString();
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

    if (!isAdmin()) {
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

  Future<User?> createUser(User user, String password) async {
    if (!await isReady()) {
      return null;
    }
    if (!isAdmin()) {
      return null;
    }
    if (!await sessionCheck()) {
      return null;
    }

    if (password.isEmpty) {
      manager.errorNotification(error: 'La contraseña no puede estar vacía');
      return null;
    }

    Map<String, dynamic> userData = user.toJson();
    userData['password'] = password;

    try {
      if (user.role == Role.adminRole) {
        var response = await requestHandler.postRequest('/user/create/admin/',
            body: userData);
        manager.notification(notification:
            'Administrador creado. Código de usuario: ${response.data['username']}');
        user.updateData(newUser: User.fromJson(response.data));
        return User.fromJson(response.data);
      } else if (user.role == Role.assistantRole) {
        var response =
            await requestHandler.postRequest('/user/create/', body: userData);
        manager.notification(notification:
            'Asistente creado. Código de usuario: ${response.data['username']}');
        user.updateData(newUser: User.fromJson(response.data));
        return User.fromJson(response.data);
      } else {
        manager.errorNotification(error: 'Ingrese un rol válido');
        return null;
      }
    } on DioException catch (e) {
      manager.errorNotification(
          error: 'Adición de usuario fallida', details: e.response?.data);
      return null;
    }
  }

  /// El administrador ya no escribe contraseñas de otras cuentas (D14):
  /// para eso genera un enlace de restablecimiento (createResetLink).
  Future<User?> updateUser(User user, {required User newUser}) async {
    if (!await isReady()) {
      return null;
    }
    if (!isAdmin()) {
      return null;
    }
    if (!await sessionCheck()) {
      return null;
    }

    var data = newUser.toJson();

    try {
      await requestHandler.patchRequest('/user/manage/',
          body: data, query: {'email': user.email});
      user.updateData(newUser: newUser);
      manager.notification(notification: 'Información de usuario actualizada');
      return User.fromJson(newUser.toJson());
    } on DioException catch (e) {
      manager.errorNotification(
          error: 'Actualización fallida', details: e.response?.data);
      return null;
    }
  }

  /// Genera un enlace de restablecimiento de contraseña (D24). Devuelve la
  /// dirección del enlace, que el servidor muestra una sola vez, o null.
  Future<String?> createResetLink(User user) async {
    if (!await isReady()) {
      return null;
    }
    if (!isAdmin()) {
      return null;
    }
    if (!await sessionCheck()) {
      return null;
    }

    try {
      var response = await requestHandler.postRequest(
          '/user/manage/reset-link/', body: {'email': user.email});
      return response.data['url'];
    } on DioException catch (e) {
      manager.errorNotification(
          error: 'No se pudo generar el enlace', details: e.response?.data);
      return null;
    }
  }

  /// Revisa un enlace de restablecimiento. Devuelve el código de usuario
  /// de la cuenta, o null si el enlace no es válido o venció.
  Future<String?> checkPasswordLink(String token) async {
    try {
      var response = await requestHandler
          .postRequest('/user/password-link/check/', body: {'token': token});
      return response.data['username'];
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
    if (!isAdmin()) {
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
    if (!isAdmin()) {
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

  Future<User?> makeAdmin(User user) async {
    if (!await isReady()) {
      return null;
    }
    if (!isAdmin()) {
      return null;
    }
    if (!await sessionCheck()) {
      return null;
    }

    if (user.role == Role.adminRole) {
      manager.notification(notification: 'Ya es administrador');
      return user;
    }

    User newUser = user.clone();
    newUser.role = Role.adminRole;
    return await updateUser(user, newUser: newUser);
  }

  /// Bitácora de seguridad (D28): los eventos más recientes primero.
  Future<List<SecurityEvent>> getSecurityEvents(
      {String? username, String? eventType}) async {
    if (!await isReady()) {
      return [];
    }
    if (!isAdmin()) {
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

  /// La gestión de cuentas corresponde al administrador de seguridad (D18).
  bool isAdmin() {
    final session = SessionManager().session;
    return session.isSecurityAdmin();
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
