import 'package:flutter/material.dart';
// import 'package:frontend/models/Session.dart'; // Comentado para ver solo la vista
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/widgets/user_form.dart';
import 'package:frontend/widgets/notification.dart';

import '../models/User.dart';
// import 'package:frontend/models/user.dart'; // Comentado para ver solo la vista

class CreateUserScreen extends StatefulWidget {
  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  bool _showNotification = false;
  String _notificationMessage = '';

  void _createUser(String email, String name, String password,
      Role role, bool isActive) {
    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      setState(() {
        _notificationMessage = "Todos los campos son obligatorios.";
        _showNotification = true;
      });
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showNotification = false;
        });
      });
      return;
    }

    User user;
    if (role == Role.adminRole) {
      user = AdminUser(email: email, name: name, isActive: isActive);
    } else {
      user = AssistUser(email: email, name: name, isActive: isActive);
    }

    user.create(password: password);
    //User newUser = User.clone(user);

    //newUser.name = newName;

    //user.update(newUser: newUser, password: password);

    setState(() {
      _notificationMessage = "Usuario '$name' creado con éxito.";
      _showNotification = true;
    });

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showNotification = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Crear Nuevo Usuario'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                BannerWidget(
                  imageUrl: "assets/images/place_holder.png",
                  title: "Gestión de Usuarios",
                  subtitle: "Crea un nuevo usuario",
                  description: "Añade un nuevo usuario al sistema.",
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: UserForm(
                    onFormSubmit: _createUser,
                  ),
                ),
              ],
            ),
          ),
          if (_showNotification)
            NotificationWidget(
              message: _notificationMessage,
              //alignment: Alignment.bottomCenter,
            ),
        ],
      ),
    );
  }
}
