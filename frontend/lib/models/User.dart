
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/services/frame_adapter.dart';
import 'package:provider/provider.dart';



class Role{
  static const Role adminRole = Role(name : "AdminRole");
  static const Role assistantRole = Role(name : "AssistantRole");
  static const Role visitorRole = Role(name : "VisitorRole");

  final String name;
  const Role({required this.name});
}



abstract class User extends ChangeNotifier{
  String email;
  String name;
  bool isActive;
  Role role;

  User({required this.email,
        required this.name,
        this.isActive = true,
        this.role = Role.assistantRole}){
    getFrameAdapter();
  }

  FrameAdapter getFrameAdapter();

  void create();

  void update();

}

class VisitorUser extends User{
  static

  User anonymousUser = VisitorUser(email: "", name: "");

  VisitorUser({required super.email, required super.name}):
        super(role: Role.visitorRole);

  @override
  FrameAdapter getFrameAdapter() {
    return VisitorFrameAdapter();
  }

  @override
  void create() {
    return;
  }

  @override
  void update() {
    return;
  }
}

class AdminUser extends User{
  AdminUser({required super.email, required super.name}):
        super(role: Role.adminRole);

  @override
  FrameAdapter getFrameAdapter() {
    return AdminFrameAdapter();
  }

  @override
  void create() {
    SessionManager.session.createUser(this);
  }

  @override
  void update() {
    SessionManager.session.updateUser(this);
  }
}


class AssistUser extends User{
  AssistUser({required super.email, required super.name}):
        super(role: Role.assistantRole);

  @override
  FrameAdapter getFrameAdapter() {
    return AssistantFrameAdapter();
  }

  @override
  void create() {
    SessionManager.session.createUser(this);
  }

  @override
  void update() {
    SessionManager.session.updateUser(this);
  }
}
