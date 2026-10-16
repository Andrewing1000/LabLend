import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';

import '../widgets/password_field.dart';
import '../widgets/string_field.dart';

class LoginScreen extends StatefulWidget {
  final Function(String username, String password) onSubmit;
  final Function() onPasswordReset;

  const LoginScreen({super.key, required this.onSubmit, required this.onPasswordReset});

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}


class LoginPageState extends State<LoginScreen>{
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            StringField(
              labelText: "Código de usuario",
              controller: userController,
              hintText: "usr.jperez",
              width: 300, // Ancho del campo de texto
            ),
            const SizedBox(height: 20),
            PasswordField(
              controller: passwordController,
              hintText: "",
              width: 300, // Ancho del campo de texto
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Validar los campos
                if (userController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty) {
                  widget.onSubmit(userController.text, passwordController.text);
                } else {
                  SessionManager().errorNotification(error: "Todos los campos son requeridos");
                }
              },
              child: const Text("Iniciar Sesión"),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                widget.onPasswordReset();
                print("Recuperar contraseña");
              },
              child: const Text(
                "Recuperar contraseña",
                style:
                TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}