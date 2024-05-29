
import 'Session.dart';
import 'User.dart';
import 'package:dio/dio.dart';

class UserManager{

  static var manager = SessionManager();
  var session = SessionManager.session;
  var user;
  var requestHandler;

  UserManager(){
    user = session.user;
    requestHandler = session.requestHandler;
  }


  Future<List<User>> getUserList({bool? isAdmin, bool? isActive, String? email}) async {
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

  Future<User> getUser(String email) async {
    if(!await isReady()){
      return VisitorUser.anonymousUser;
    }
    if(!await sessionCheck()){
      return VisitorUser.anonymousUser;
    }

    if(user.email == email){
      var response = await requestHandler.getRequest('/user/me');
      return User.fromJson(response.data);
    }


    if(!isAdmin()){
      return VisitorUser.anonymousUser;
    }


    try{
      var response = await requestHandler.getRequest('/user/manage', query: {'email' : email});
      return User.fromJson(response.data);
    }on  DioException catch(e){
      if(e.response?.statusCode == 404){
        manager.errorNotification(error : 'No se encontró a un usuario con ese email');
      }
      else{
        manager.errorNotification(error : "", details : e.response?.data);
      }
      return VisitorUser.anonymousUser;
    }
  }

  Future<User> createUser(User user, String password) async {
    if(!await isReady()){
      return VisitorUser.anonymousUser;
    }
    if(!isAdmin()){
      return VisitorUser.anonymousUser;
    }
    if(!await sessionCheck()){
      return VisitorUser.anonymousUser;
    }

    if(password == ""){
      manager.errorNotification(error: 'El password no puede estar vacío');
      return user;
    }

    Map<String, dynamic> userData = user.toJson();
    userData['password'] = password;

    if(user.role == Role.adminRole || user.role == Role.superAdminRole){
      try{
        var response = await requestHandler.postRequest('/user/create/admin/', body: userData);
        manager.notification(notification: 'Administrador creado');
        return user;
      }on DioException catch(e){
        manager.errorNotification(error: "Adición de usuario fallida", details: e.response?.data);
        return VisitorUser.anonymousUser;
      }

    }
    else if(user.role == Role.assistantRole){
      try{
        await requestHandler.postRequest('/user/create/', body: userData);
        manager.notification(notification: 'Asistente creado');
        return user;
      }on DioException catch(e){
        manager.errorNotification(error: "Adición de usuario fallida", details: e.response?.data);
        return VisitorUser.anonymousUser;
      }

    }
    else{
      manager.errorNotification(error: "Ingrese un rol válido");
    }

    return user;
  }

  Future<User> updateUser(User user,  {required User newUser, String? password}) async {

    if(!await isReady()){
      return VisitorUser.anonymousUser;
    }
    if(!isAdmin()){
      return VisitorUser.anonymousUser;
    }
    if(!await sessionCheck()){
      return VisitorUser.anonymousUser;
    }


    if(user.role == Role.adminRole || user.role == Role.superAdminRole){
      try{
        requestHandler.patchRequest('/user/manage/', body: newUser.toJson(), query: {'email': user.email});
        user.updateData(newUser: newUser);
        manager.notification(notification: "Información de usuaro actualizada");
      }on DioException catch(e){
        manager.errorNotification(error: "Actualización fallida", details: e.response?.data);
      }

    }
    else if(user.role == Role.assistantRole){
      try{
        var response = requestHandler.patchRequest('/user/manage/', body: newUser.toJson(), query: {'email': user.email});
        user.updateData(newUser: newUser);
        manager.notification(notification: "Información de usuaro actualizada");
      }on DioException catch(e){
        manager.errorNotification(error: "Actualización fallida", details: e.response?.data);
      }

    }
    else{
      manager.errorNotification(error: "Rol inválido");
    }

    return user;
  }


  Future<User> disableUser(User user) async {

    User newUser = user.clone();
    newUser.isActive = false;
    return updateUser(user, newUser: newUser);
  }


  Future<User> enableUser(User user) async {

    if(!isAdmin()){
      //Implement notification
      return VisitorUser.anonymousUser;
    }
    isReady();

    User newUser = user.clone();
    newUser.isActive = true;
    return updateUser(user, newUser: newUser);
  }



  Future<User> makeAdmin(User user) async{
    if(!await isReady()){
      return VisitorUser.anonymousUser;
    }
    if(!isAdmin()){
      return VisitorUser.anonymousUser;
    }
    if(!await sessionCheck()){
      return VisitorUser.anonymousUser;
    }

    if(user.role == Role.adminRole || user.role == Role.superAdminRole){
      manager.notification(notification: "Ya es administrador");
      return user;
    }

    User newUser = user.clone();
    newUser.role = Role.adminRole;
    return updateUser(user, newUser: newUser);
  }

  bool isAdmin() {
    return session.isAdmin();
  }

  Future<bool> sessionCheck() async {
    return await session.sessionCheck();
  }

  Future<bool> isReady() async {
    return await session.isReady();
  }

}