
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';



class Role{
  static const Role adminRole = Role(name : "AdministradorLaboratorio");
  static const Role assistantRole = Role(name : "AsistenteLaboratorio");
  static const Role securityAdminRole = Role(name : "AdministradorSeguridad");
  static const Role visitorRole = Role(name : "VisitorRole");

  final String name;
  const Role({required this.name});
}



abstract class User extends ChangeNotifier{
  int? id;
  /// Código de usuario (User ID) generado por el servidor, p. ej. usr.jperez.
  String username;
  String email;
  String nombres;
  String apellidoPaterno;
  String apellidoMaterno;
  bool isActive;
  Role role;

  User({
        int? id,
        this.username = '',
        required this.email,
        required this.nombres,
        required this.apellidoPaterno,
        this.apellidoMaterno = '',
        this.isActive = true,
        this.role = Role.assistantRole});

  String get name => [nombres, apellidoPaterno, apellidoMaterno]
      .where((part) => part.isNotEmpty)
      .join(' ');


  factory User.fromJson(Map<String, dynamic> userData){
    String? roleField = userData['role_field'];
    User user = VisitorUser.anonymousUser;
    if(roleField == Role.adminRole.name){
      user = AdminUser(
        id: userData['id'],
        username: userData['username'] ?? '',
        email: userData['email'],
        nombres: userData['nombres'] ?? '',
        apellidoPaterno: userData['apellido_paterno'] ?? '',
        apellidoMaterno: userData['apellido_materno'] ?? '',
        isActive : userData['is_active'],
      );
    }
    else if(roleField == Role.assistantRole.name){
      user = AssistUser(
        id: userData['id'],
        username: userData['username'] ?? '',
        email: userData['email'],
        nombres: userData['nombres'] ?? '',
        apellidoPaterno: userData['apellido_paterno'] ?? '',
        apellidoMaterno: userData['apellido_materno'] ?? '',
        isActive : userData['is_active'],
      );
    }
    else if(roleField == Role.securityAdminRole.name){
      user = SecurityAdminUser(
        id: userData['id'],
        username: userData['username'] ?? '',
        email: userData['email'],
        nombres: userData['nombres'] ?? '',
        apellidoPaterno: userData['apellido_paterno'] ?? '',
        apellidoMaterno: userData['apellido_materno'] ?? '',
        isActive : userData['is_active'],
      );
    }

    return user;
  }


  Map<String, dynamic> toJson(){
    return {
      'id' : id,
      'username' : username,
      'email' : email,
      'nombres' : nombres,
      'apellido_paterno' : apellidoPaterno,
      'apellido_materno' : apellidoMaterno,
      'role_field' : role.name,
      'is_active' : isActive,
    };
  }

  User clone(){
    return User.fromJson(toJson());
  }


  Future<User?> create({required String password}) async {
    return await SessionManager.userManager.createUser(this, password);
  }

  Future<User?> update({required User newUser}) async {
    return await SessionManager.userManager.updateUser(this, newUser: newUser);
  }

  Future<String?> createResetLink() async {
    return await SessionManager.userManager.createResetLink(this);
  }

  void deactivate(){
    SessionManager.userManager.disableUser(this);
  }

  void activate(){
    SessionManager.userManager.enableUser(this);
  }

  void updateData({required User newUser}) {
    username = newUser.username;
    email = newUser.email;
    nombres = newUser.nombres;
    apellidoPaterno = newUser.apellidoPaterno;
    apellidoMaterno = newUser.apellidoMaterno;
    isActive =  newUser.isActive;
    role = newUser.role;
    notifyListeners();
  }
}

class VisitorUser extends User{
  static

  User anonymousUser = VisitorUser(email: "", nombres: "", apellidoPaterno: "");

  VisitorUser({required super.email, required super.nombres,
    required super.apellidoPaterno, super.id}):
        super(role: Role.visitorRole);
}

class AdminUser extends User{
  AdminUser({super.username, required super.email, required super.nombres,
    required super.apellidoPaterno, super.apellidoMaterno, super.isActive,
    super.id}):
        super(role: Role.adminRole);
}


/// Administrador de seguridad: gestiona cuentas de usuario, no el
/// inventario ni los préstamos (D18).
class SecurityAdminUser extends User{
  SecurityAdminUser({super.username, required super.email, required super.nombres,
    required super.apellidoPaterno, super.apellidoMaterno, super.isActive,
    super.id}):
        super(role: Role.securityAdminRole);
}


class AssistUser extends User{
  AssistUser({super.username, required super.email, required super.nombres,
    required super.apellidoPaterno, super.apellidoMaterno, super.isActive,
    super.id}):
        super(role: Role.assistantRole);

}
