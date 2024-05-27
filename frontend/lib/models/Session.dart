import 'dart:core';

import 'package:frontend/models/Request.dart';
import 'package:dio/dio.dart';
import 'package:frontend/services/frame_adapter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'Item.dart';
import 'User.dart';


class Session {
  static final SessionManager manager = SessionManager();
  final User user;
  final DateTime loginTime;
  final Widget mainFrame = manager.mainFrame;
  final RequestHandler requestHandler;

  Session({required this.user, required this.loginTime}):
  requestHandler = SessionManager.httpHandler{
    FrameAdapter adapter = user.getFrameAdapter();
    adapter.setUpFrame(mainFrame);
  }

  void logOut(){
    manager.logOut();
  }


  Future<bool> sessionCheck() async {
    return await manager.sessionCheck();
  }

  Future<bool> connectionCheck() async{
    return await manager.connectionCheck();
  }

  bool isAdmin(){
    if(user is AdminUser){
      return true;
    }
    manager.errorNotification(error: "Acción denegada");
    return false ;
  }

  Future<bool> isReady() async{
    //Implement login
    return await connectionCheck();
  }



  Future<List<User>> getUserList() async {
    if(!await isReady()){
      return [];
    }
    if(!isAdmin()){
      return [];
    }
    if(!await sessionCheck()){
      return [];
    }

    var response;
    try {
      response = await requestHandler.getRequest('/api/user/list/');
    }on DioException catch(e) {
      manager.errorNotification(error : '' , details : e.response?.data);
      return [];
    }

      List<User> userList = [];
      for(var userData in response.data['results']){
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
      var response = await requestHandler.getRequest('/api/user/me');
      return User.fromJson(response.data);
    }


    if(!isAdmin()){
      return VisitorUser.anonymousUser;
    }


    try{
      var response = await requestHandler.getRequest('/api/user/manage', query: {'email' : email});
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
    return user;
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
        var response = await requestHandler.postRequest('/api/user/create/admin/', body: userData);
        manager.notification(notification: 'Administrador creado');
        return user;
      }on DioException catch(e){
        manager.errorNotification(error: "Adición de usuario fallida", details: e.response?.data);
        return VisitorUser.anonymousUser;
      }

    }
    else if(user.role == Role.assistantRole){
      try{
        var response = requestHandler.postRequest('/api/user/create/', body: userData);
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
        var response = requestHandler.patchRequest('/api/user/manage/', body: newUser.toJson(), query: {'email': user.email});
        user.updateData(newUser: newUser);
        manager.notification(notification: "Información de usuaro actualizada");
      }on DioException catch(e){
        manager.errorNotification(error: "Actualización fallida", details: e.response?.data);
      }

    }
    else if(user.role == Role.assistantRole){
      try{
        var response = requestHandler.patchRequest('/api/user/manage/', body: newUser.toJson(), query: {'email': user.email});
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

    User newUser = User.clone(user);
    newUser.isActive = false;
    return updateUser(user, newUser: newUser);
  }


  Future<User> enableUser(User user) async {

    if(!isAdmin()){
      //Implement notification
      return VisitorUser.anonymousUser;
    }
    isReady();

    User newUser = User.clone(user);
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

    User newUser = User.clone(user);
    newUser.role = Role.adminRole;
    return updateUser(user, newUser: newUser);
  }

  Future<List<Item>> getEquipmentList() async {
    if(isAdmin()){
      //Implement notification
      return [];
    }


    return [];
  }



  Future<Item> getItem(String id) async {

    //Check if user doesent exists
    //Check permisssions


    return Item();
  }


  Future<Item> createItem(Item item) async {

    if(isAdmin()){
      //Implement notification
      return Item();
    }
    //Check if user doesent exists
    //Check permisssions


    return Item();
  }

  Future<Item> deleteItem(Item item) async {

    if(isAdmin()){
      //Implement notification
      return Item();
    }
    //Check if user doesent exists
    //Check permisssions


    return Item();
  }


  Future<Item> updateItem(Item item) async {

    if(isAdmin()){
      //Implement notification
      return Item();
    }

    //Check if user doesent exists
    //Check permisssions

    return Item();
  }

}


class AnonymousSession extends Session{
  AnonymousSession():super(user: VisitorUser.anonymousUser, loginTime: DateTime.now());
}


class SessionManager with ChangeNotifier {
  bool _isOnline = false;
  static SessionManager manager = SessionManager._inner();
  static Session _session = AnonymousSession();
  static RequestHandler httpHandler = RequestHandler();

  Widget mainFrame = Container();

  ///
  ///
  ///
  ///
  ///
  ///Constructors
  SessionManager._inner(){
    connectionCheck();
  }

  factory SessionManager(){
    manager ??= SessionManager._inner();
    return manager;
  }


  static Session get session => _session;

  static set session(Session session){
    _session = session;
  }

  bool get isOnline => _isOnline;

  ///
  ///
  ///
  /// Notify MainFrame
  void errorNotification({required String error, Map<String, dynamic>? details}){
    print(error);

    for(String key in details!.keys){
      print(key + ": " + details[key].toString());
    }
  }

  void notification({required String notification}){
    print(notification);

  }

  void confirmNotification(){

  }


  ///
  ///
  ///
  ///Online status manager
  set isOnline(bool online){
    if(online){
      _setOnline();
      return;
    }
    _setOffline();
    return;
  }

  void _setOffline(){
    //implement
    _isOnline = false;
  }

  void _setOnline(){
    //implement
    _isOnline = true;
  }

  Future<bool> sessionCheck() async{
    try{
      var response = await httpHandler.getRequest('/api/user/me/');
      if(response.statusCode == 200){
        return true;
      }
      return false;
    }on DioException catch (e){
      session = AnonymousSession();
    }

    errorNotification(error: 'Inicie sesión');
    return false;
  }


  Future<bool> connectionCheck() async{
    isOnline = await httpHandler.connectionCheck();

    if(!isOnline){
      errorNotification(error : 'Sin conección');
    }

    return isOnline;
  }



  ///
  ///
  ///
  ///Login management
  Future<Session> login(String email, String password) async {
    if(!(await connectionCheck())){return AnonymousSession();};

    if(_session is!  AnonymousSession){
      if(session?.user.email == email){
        if(await sessionCheck()){
          return _session;
        }
      }
      else{
        logOut();
      }
    }

    Map<String, String> data = {
      'email' : email,
      'password' : password,
    };

    try{
      var response = await httpHandler.postRequest('/api/user/token/', body: data);
      User user = User.fromJson(response.data);

      if(!user.isActive){
        errorNotification(error :'La cuenta no está habilitada');
        return AnonymousSession();
      }

      notification(notification : 'Sesión iniciada');
      _session = Session(user: user, loginTime: DateTime.now());
      return _session;

    } on DioException catch(e){

      if(e.response?.statusCode == 404){

        errorNotification(error : 'Usuario no registrado');
        //Not found
        return AnonymousSession();
      }
      else if(e.response?.statusCode == 401){

        //Bad credentials
        errorNotification(error: 'Credenciales inválidas');
        return AnonymousSession();
      }
      else if(e.response?.statusCode == 429){

        //Too many attempts
        errorNotification(error :'Muchos intentos, intente de nuevo más tarde');
        return AnonymousSession();
      }
      else{

        print("Unknown Error");
        return AnonymousSession();
      }
    }
  }


  void logOut() async{
    if(!(await connectionCheck())){
      return;
    };

    if(!(await sessionCheck())){
      return;
    }

    var response = await httpHandler.postRequest('/api/user/logout/');

    if(response.statusCode == 200){
      errorNotification(error : 'Sesión cerrada');
      _session = AnonymousSession();
    }
    else if(response.statusCode == 412){
      errorNotification(error :'Primero inicie sesión');
      _session = AnonymousSession();
    }
    else{
      errorNotification(error :'Sesión cerrada');
      _session = AnonymousSession();
    }
  }
}