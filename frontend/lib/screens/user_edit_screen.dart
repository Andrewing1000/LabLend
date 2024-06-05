import 'package:flutter/material.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/models/User.dart';
//import 'package:frontend/models/User.dart';
import 'package:frontend/models/Session.dart';

import '../widgets/user_form.dart';

class EditUserScreen extends PageBase{

  User user;
  EditUserScreen({super.key, required this.user}):
        super(disposable: true);

  @override
  EditUserScreenState createState() => EditUserScreenState();

  @override
  void onDispose() {
    return;
  }

  @override
  void onSet() {
    return;
  }
}

class EditUserScreenState extends State<EditUserScreen> {


  Future<void> _updateUser(String email, String name, String password,
      Role role, bool isActive) async {
    if (email.isEmpty && name.isEmpty && password.isEmpty &&
        role==widget.user.role &&
        isActive==widget.user.isActive) {
      SessionManager().errorNotification(error: "No se registraron cambios");
      return;
    }

    User newUser = widget.user.clone();

    bool noEdits = true;
    if(email != newUser.email && email.isNotEmpty){
      noEdits = false;
      newUser.email = email;
    }
    if(name != newUser.name && name.isNotEmpty){
      noEdits = false;
      newUser.name = name;
    }
    if(password.isNotEmpty){
      noEdits = false;
    }
    if(role != newUser.role){
      noEdits = false;
      newUser.role = role;
    }
    if(isActive != newUser.isActive){
      noEdits = false;
      newUser.isActive = isActive;
    }

    if(noEdits){
      SessionManager().errorNotification(error: "No se registraron cambios");
      return;
    }


    var res = await widget.user.update(newUser: newUser, password: password.isNotEmpty? password:null);
    if(res != null){
      widget.manager?.removePage();
    }

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
                  title: "Edición de usuarios",
                  subtitle: "",
                  description: ""),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: UserForm(
                  user: widget.user,
                  onFormSubmit: _updateUser,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
