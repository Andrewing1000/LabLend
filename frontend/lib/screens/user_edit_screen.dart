import 'package:flutter/material.dart';
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/widgets/user_edit_form.dart';
import 'package:frontend/widgets/notification.dart';
import 'package:frontend/models/User.dart';
//import 'package:frontend/models/User.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/widgets/string_field.dart';

class EditUserScreen extends StatefulWidget {
  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  bool _showNotification = false;
  String _notificationMessage = '';
  User? user;
  final TextEditingController emailController = TextEditingController();

  void _getUser() async {
    User? fetchedUser =
        await SessionManager.userManager.getUser(emailController.text);
    setState(() {
      user = fetchedUser;
    });
  }

  void _updateUser(String name, String password, Role role, bool isActive) {
    if (user == null) return;

    User newUser = user!.clone();
    newUser.name = name;
    newUser.role = role;
    newUser.isActive = isActive;
    user!.update(newUser: newUser, password: password);

    setState(() {
      _notificationMessage = "Usuario '$name' actualizado con éxito.";
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
        title: Text('Editar Usuario'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                BannerWidget(
                  imageUrl: "https://via.placeholder.com/150",
                  title: "Gestión de Usuarios",
                  subtitle: "Editar usuario",
                  description: "Modifica los datos del usuario seleccionado.",
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: user == null
                      ? Column(
                          children: [
                            StringField(
                              controller: emailController,
                              hintText: 'Correo Electrónico',
                              width: MediaQuery.of(context).size.width * 0.8,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _getUser,
                              child: Text('Buscar Usuario'),
                            ),
                          ],
                        )
                      : UserEditForm(
                          user: user!,
                          onFormSubmit: _updateUser,
                        ),
                ),
              ],
            ),
          ),
          if (_showNotification)
            NotificationWidget(
              message: _notificationMessage,
            ),
        ],
      ),
    );
  }
}
