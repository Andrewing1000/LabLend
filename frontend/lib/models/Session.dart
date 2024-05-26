import 'dart:core';

import 'package:frontend/models/Request.dart';
import 'package:dio/dio.dart';
import 'package:frontend/services/frame_adapter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
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



  Future<User> getUser(String email) async {

    //Check if user doesent exists
    //Check permisssions


    return user;
  }




  Future<User> createUser(User user) async {

    //Check if user doesent exists
    //Check permisssions


    return user;
  }


  Future<User> updateUser(User user) async {


    //Check if user doesent exists
    //Check permisssions

    return user;
  }


  Future<User> disableUser(User user) async {
    user.isActive = false;
    return updateUser(user);
  }

  Future<User> makeAdmin() async{
    user.role = Role.adminRole;
    return updateUser(user);
  }


  Future<List<Map<String, String>>> getEquipmentList() async {
      return [];
  }



  Future<User> getItem(User user) async {

    //Check if user doesent exists
    //Check permisssions


    return user;
  }


  Future<User> createItem(User user) async {

    //Check if user doesent exists
    //Check permisssions


    return user;
  }

  Future<User> deleteItem(User user) async {

    //Check if user doesent exists
    //Check permisssions


    return user;
  }


  Future<User> updateItem(User user) async {


    //Check if user doesent exists
    //Check permisssions

    return user;
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

  bool get isOnline => _isOnline;

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
    var response = await httpHandler.getRequest('api/user/me/');

    if(response.statusCode == 200){
      return true;
    }
    return false;
  }


  Future<bool> connectionCheck() async{
    isOnline = await httpHandler.connectionCheck();
    return isOnline;
  }



  ///
  ///
  ///
  ///Login management
  Future<Session?> login(String email, String password) async {
    connectionCheck();

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

      if(!response.data['is_active']){
        return AnonymousSession();
      }

      User user;
      if(response.data['role_field'] == 'AdministradorLaboratorio' ||
          response.data['role_field'] == 'SuperAdmin'){
        user = AdminUser(
          email : response.data['email'],
          name: response.data['name'],
        );
      }
      else if(response.data['role_field'] == 'AdministradorLaboratorio'){
        user = AssistUser(
          email : response.data['email'],
          name: response.data['name'],
        );
      }
      else{
        user = VisitorUser.anonymousUser;
      }

      _session = Session(user: user, loginTime: DateTime.now());
      return _session;

    } on DioException catch(e){

      if(e.response?.statusCode == 404){

        print("User not found");
        //Not found
        return AnonymousSession();
      }
      else if(e.response?.statusCode == 401){

        //Bad credentials
        print("Not correct credentials");
        return AnonymousSession();
      }
      else if(e.response?.statusCode == 429){

        //Too many attempts
        print("Too many attempts");
        return AnonymousSession();
      }
      else{

        print("Unknown Error");
        return AnonymousSession();
      }
    }
  }


  void logOut() async{

    connectionCheck();

    if(_session is AnonymousSession){
      print("Session wasnt opened");
      return;
    }

    var response = await httpHandler.postRequest('/api/user/logout/');

    if(response.statusCode == 200){
      print("Logged Out");
      _session = AnonymousSession();
    }
    else if(response.statusCode == 412){
      print("Session wasnt opened");
      _session = AnonymousSession();
    }
    else{
      print("Session closed");
      _session = AnonymousSession();
    }
  }
}