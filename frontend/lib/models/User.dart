import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/services/frame_adapter.dart';
import 'package:provider/provider.dart';

class Role {
  static const Role adminRole = Role(name: "AdministradorLaboratorio");
  static const Role superAdminRole = Role(name: "SuperAdmin");
  static const Role assistantRole = Role(name: "AsistenteLaboratorio");
  static const Role visitorRole = Role(name: "VisitorRole");

  final String name;
  const Role({required this.name});
}

abstract class User extends ChangeNotifier {
  String email;
  String name;
  bool isActive;
  Role role;

  User(
      {required this.email,
      required this.name,
      this.isActive = true,
      this.role = Role.assistantRole}) {
    getFrameAdapter();
  }

  factory User.fromJson(Map<String, dynamic> userData) {
    String roleField = userData['role_field'];
    User user = VisitorUser.anonymousUser;
    if (roleField == Role.adminRole.name ||
        roleField == Role.superAdminRole.name) {
      user = AdminUser(
        email: userData['email'],
        name: userData['name'],
        isActive: userData['is_active'],
      );
    } else if (roleField == Role.assistantRole.name) {
      user = AssistUser(
        email: userData['email'],
        name: userData['name'],
        isActive: userData['is_active'],
      );
    }

    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'role_field': role.name,
      'is_active': isActive,
    };
  }

  FrameAdapter getFrameAdapter();

  User clone() {
    return User.fromJson(toJson());
  }

  void create({required String password}) {
    SessionManager.userManager.createUser(this, password);
    return;
  }

  void update({required User newUser, String? password}) {
    SessionManager.userManager
        .updateUser(this, newUser: newUser, password: password);
    return;
  }

  void deactivate() {
    SessionManager.userManager.disableUser(this);
  }

  void activate() {
    SessionManager.userManager.enableUser(this);
  }

  void updateData({required User newUser}) {
    email = newUser.email;
    name = newUser.name;
    isActive = newUser.isActive;
    role = newUser.role;
    notifyListeners();
  }
}

class VisitorUser extends User {
  static User anonymousUser = VisitorUser(email: "", name: "");

  VisitorUser({required super.email, required super.name})
      : super(role: Role.visitorRole);

  @override
  FrameAdapter getFrameAdapter() {
    return VisitorFrameAdapter();
  }
}

class AdminUser extends User {
  AdminUser({required super.email, required super.name, super.isActive})
      : super(role: Role.adminRole);

  @override
  FrameAdapter getFrameAdapter() {
    return AdminFrameAdapter();
  }
}

class AssistUser extends User {
  AssistUser({required super.email, required super.name, super.isActive})
      : super(role: Role.assistantRole);

  @override
  FrameAdapter getFrameAdapter() {
    return AssistantFrameAdapter();
  }
}
