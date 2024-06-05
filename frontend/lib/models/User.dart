
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:provider/provider.dart';



class Role{
  static const Role adminRole = Role(name : "AdministradorLaboratorio");
  static const Role superAdminRole = Role(name : "SuperAdmin");
  static const Role assistantRole = Role(name : "AsistenteLaboratorio");
  static const Role visitorRole = Role(name : "VisitorRole");

  final String name;
  const Role({required this.name});
}



abstract class User extends ChangeNotifier{
  int? id;
  String email;
  String name;
  bool isActive;
  Role role;

  User({
        int? id,
        required this.email,
        required this.name,
        this.isActive = true,
        this.role = Role.assistantRole}){
    if(name.isEmpty){
      name = "Super User";
    }
  }


  factory User.fromJson(Map<String, dynamic> userData){
    String roleField = userData['role_field'];
    User user = VisitorUser.anonymousUser;
    if(roleField == Role.adminRole.name || roleField == Role.superAdminRole.name){
      user = AdminUser(
        id: userData['id'],
        email: userData['email'],
        name: userData['name'],
        isActive : userData['is_active'],
      );
    }
    else if(roleField == Role.assistantRole.name){
      user = AssistUser(
        id: userData['id'],
        email: userData['email'],
        name: userData['name'],
        isActive : userData['is_active'],
      );
    }

    return user;
  }


  Map<String, dynamic> toJson(){
    return {
      'id' : id,
      'email' : email,
      'name' : name,
      'role_field' : role.name,
      'is_active' : isActive,
    };
  }

  User clone(){
    return User.fromJson(toJson());
  }


  void create({required String password}) {
    print("------------------------->A");
    SessionManager.userManager.createUser(this, password);
    return;
  }

  Future<User?> update({required User newUser, String? password}) async {

    return await SessionManager.userManager.updateUser(this, newUser: newUser, password: password);
  }

  void deactivate(){
    SessionManager.userManager.disableUser(this);
  }

  void activate(){
    SessionManager.userManager.enableUser(this);
  }

  void updateData({required User newUser}) {
    email = newUser.email;
    name = newUser.name;
    isActive =  newUser.isActive;
    role = newUser.role;
    notifyListeners();
  }
}

class VisitorUser extends User{
  static

  User anonymousUser = VisitorUser(email: "", name: "");

  VisitorUser({required super.email, required super.name, super.id}):
        super(role: Role.visitorRole);
}

class AdminUser extends User{
  AdminUser({required super.email, required super.name, super.isActive, super.id}):
        super(role: Role.adminRole);
}


class AssistUser extends User{
  AssistUser({required super.email, required super.name, super.isActive, super.id}):
        super(role: Role.assistantRole);

}
