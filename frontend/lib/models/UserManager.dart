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
      manager.errorNotification(error: 'El password no puede estar vacío');
      return null;
    }

    Map<String, dynamic> userData = user.toJson();
    userData['password'] = password;

    try {
      if (user.role == Role.adminRole || user.role == Role.superAdminRole) {
        var response = await requestHandler.postRequest('/user/create/admin/',
            body: userData);
        manager.notification(notification: 'Administrador creado');
        user.updateData(newUser: User.fromJson(response.data));
        return User.fromJson(response.data);
      } else if (user.role == Role.assistantRole) {
        var response =
            await requestHandler.postRequest('/user/create/', body: userData);
        manager.notification(notification: 'Asistente creado');
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

  Future<User?> updateUser(User user,
      {required User newUser, String? password}) async {
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
    if(password!=null){
      data['password'] = password;
    }

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

    if (user.role == Role.adminRole || user.role == Role.superAdminRole) {
      manager.notification(notification: 'Ya es administrador');
      return user;
    }

    User newUser = user.clone();
    newUser.role = Role.adminRole;
    return await updateUser(user, newUser: newUser);
  }

  bool isAdmin() {
    final session = SessionManager().session;
    return session.isAdmin();
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
