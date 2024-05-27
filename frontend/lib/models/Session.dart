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
    return user is AdminUser;
  }

  Future<bool> isReady() async{
    //Implement login
    return await sessionCheck() && await connectionCheck();
  }



  Future<List<User>> getUserList() async {
    //isReady();
    // if(!isAdmin()){
    //   //Implement notification
    //   print("Not enough permissions");
    //   return [];
    // }

    var response = await requestHandler.getRequest('/api/user/list/');

    List<User> userList = [];
    for(var userData in response.data['results']){
      var user = User.fromJson(userData);
      userList.add(user);
    }

    return userList;
  }

  Future<User> getUser(String email) async {
    isReady();
    if(user.email == email){
      var response = await requestHandler.getRequest('/api/user/me');
      return User.fromJson(response.data);
    }

    if(!isAdmin()){
      //Implement notification
      print("Not valid permissions");
      return VisitorUser.anonymousUser;
    }

    try{
      var response = await requestHandler.getRequest('/api/user/manage', query: {'email' : email});
      return User.fromJson(response.data);
    }on  DioException catch(e){
      if(e.response?.statusCode == 404){
        print("User not found");
      }
      return VisitorUser.anonymousUser;
    }
    return user;
  }

  Future<User> createUser(User user, String password) async {
    //isReady();

    // if(!isAdmin()){
    //   //Implement notification
    //   print('Not valid permissions');
    //   return VisitorUser.anonymousUser;
    // }

    if(password == ""){
      print("Password cannot be empty");
      return user;
    }

    Map<String, dynamic> userData = user.toJson();
    userData['password'] = password;

    var response;
    if(user.role == Role.adminRole || user.role == Role.superAdminRole){
      try{
        response = requestHandler.postRequest('/api/user/create/admin/', body: userData);
        print("User Created");
      }on DioException catch(e){
        print("Error");
      }

    }
    else if(user.role == Role.assistantRole){
      try{
        response = requestHandler.postRequest('/api/user/create/', body: userData);
        print("User Created");
      }on DioException catch(e){
        print("Error");
      }

    }
    else{
      print("Cannot create visitor user");
    }

    return user;
  }

  Future<User> updateUser(User user,  {required User newUser, String? password}) async {

    isReady();
    if(!isAdmin()){
      //Implement notification
      print('Not valid permissions');
      return VisitorUser.anonymousUser;
    }

    if(user.email != newUser.email){
      print("Email cannot be changed");
      return user;
    }

    Map<String, dynamic> userData = newUser.toJson();
    if(password != null){
      userData['password'] = password;
    }


    var response;
    if(user.role == Role.adminRole || user.role == Role.superAdminRole){
      try{
        response = requestHandler.patchRequest('/api/user/manage/', body: userData, query: {'email': user.email});
        user.updateData(newUser: newUser);
        print("User Updated");
      }on DioException catch(e){
        print("Error");
      }

    }
    else if(user.role == Role.assistantRole){
      try{
        response = requestHandler.patchRequest('/api/user/manage/', body: userData, query: {'email': user.email});
        user.updateData(newUser: newUser);
        print("User Updated");
      }on DioException catch(e){
        print("Error");
      }

    }
    else{
      print("Cannot update user");
    }

    return user;
  }


  Future<User> disableUser(User user) async {

    if(!isAdmin()){
      //Implement notification
      return VisitorUser.anonymousUser;
    }
    isReady();

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
    if(!isAdmin()){
      //Implement notification
      return user;
    }

    if(user.role == Role.adminRole || user.role == Role.superAdminRole){
      print("Already admin");
      return user;
    }

    isReady();

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
    var response = await httpHandler.getRequest('/api/user/me/');

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
  Future<Session> login(String email, String password) async {
    //connectionCheck();

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
        print('Not available account');
        return AnonymousSession();
      }

      print("Logged in");
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