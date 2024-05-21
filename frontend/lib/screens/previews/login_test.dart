import 'package:flutter/material.dart';
import '../../widgets/string_field.dart';
import '../../widgets/password_field.dart';

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatelessWidget {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
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
                hintText: "Usuario",
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
                  } else {
                    print("Todos los campos son obligatorios.");
                  }
                },
                child: Text("Iniciar Sesión"),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Lógica para recuperar contraseña
                  print("Recuperar contraseña");
                },
                child: Text(
                  "Recuperar contraseña",
                  style: TextStyle(color: const Color.fromARGB(255, 243, 222, 33)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
