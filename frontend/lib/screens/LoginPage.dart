import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';

import '../widgets/password_field.dart';
import '../widgets/string_field.dart';



class LoginScreen extends StatefulWidget {
  final Function(String email, String password) onSubmit;
  final Function() onPasswordReset;

  LoginScreen({super.key, required this.onSubmit, required this.onPasswordReset});

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
              controller: userController,
              hintText: "email",
              width: 300, // Ancho del campo de texto
            ),
            SizedBox(height: 20),
            PasswordField(
              controller: passwordController,
              hintText: "Contraseña",
              width: 300, // Ancho del campo de texto
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Validar los campos
                if (userController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty) {
                  print("Usuario: ${userController.text}");
                  print("Contraseña: ${passwordController.text}");

                  widget.onSubmit(userController.text, passwordController.text);
                } else {
                  SessionManager().errorNotification(error: "Todos los campos son requeridos");
                }
              },
              child: Text("Iniciar Sesión"),
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
                TextStyle(color: Color.fromARGB(255, 243, 222, 33)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}