// ignore_for_file: unused_import, unnecessary_import

import 'dart:core';

import 'package:frontend/models/Request.dart';
import 'package:dio/dio.dart';
import 'package:frontend/models/UserManager.dart';
import 'package:frontend/services/frame_adapter.dart';
import 'Inventory.dart';
import 'item.dart';
import 'LoanService.dart';
import 'User.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

}


class AnonymousSession extends Session{
  AnonymousSession():super(user: VisitorUser.anonymousUser, loginTime: DateTime.now());
}


class SessionManager with ChangeNotifier {
  bool _isOnline = false;
  static SessionManager manager = SessionManager._inner();
  static Session _session = AnonymousSession();
  static RequestHandler httpHandler = RequestHandler();

  static UserManager userManager = UserManager();
  static Inventory inventory = Inventory();
  static LoanService loanService = LoanService(httpHandler);

  Widget mainFrame = Container();

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