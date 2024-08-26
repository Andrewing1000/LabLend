import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';

import '../widgets/password_field.dart';
import '../widgets/string_field.dart';

import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  final Function(String email, String password) onSubmit;
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
              labelText: "email",
              controller: userController,
              hintText: "",
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
                  print("Usuario: ${userController.text}");
                  print("Contraseña: ${passwordController.text}");

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
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () async {
                var url = 'https://accounts.google.com/';
                  if (await canLaunch( url)) {
                    // ignore: deprecated_member_use
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                    }
                },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                    'assets/images/google_auth.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}