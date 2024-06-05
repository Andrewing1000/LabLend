import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
// import 'package:frontend/models/Session.dart'; // Comentado para ver solo la vista
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/widgets/user_form.dart';

import '../models/User.dart';
// import 'package:frontend/models/user.dart'; // Comentado para ver solo la vista

class CreateUserScreen extends PageBase{
  CreateUserScreen({super.key});

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();

  @override
  Future<PageBase> onDispose() async{
    return this;
  }

  @override
  Future<PageBase> onSet() async{
    return this;
  }
}

class _CreateUserScreenState extends State<CreateUserScreen> {


  Future<void> _createUser(String email, String name, String password,
      Role role, bool isActive) async {
    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      SessionManager().errorNotification(error: "Tolos los campos son obligatorios");
      return;
    }

    User user;
    if (role == Role.adminRole) {
      user = AdminUser(email: email, name: name, isActive: isActive);
    } else {
      user = AssistUser(email: email, name: name, isActive: isActive);
    }

    user.create(password: password);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const BannerWidget(
                    imageUrl: null,
                    title: "Registro de usuarios",
                    subtitle: "",
                    description: ""),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: UserForm(
                    onFormSubmit: _createUser,
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }
}
