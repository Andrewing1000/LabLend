import 'package:flutter/material.dart';
import '/widgets/password_field.dart';

void main() {
  final TextEditingController passwordController = TextEditingController(text: ""); // Controlador con valor inicial

  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Espaciado alrededor del contenido
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Widget PasswordField con estética Spotify
              PasswordField(
                controller: passwordController,
                hintText: "Contraseña",
                width: 300, // Ancho del campo de texto
              ),
              const SizedBox(height: 20),
              // Botón para imprimir la contraseña en consola (solo para pruebas)
              ElevatedButton(
                onPressed: () {
                  print("Password: ${passwordController.text}");
                },
                child: const Text("mostrar Constraseña"),
              ),
            ],
          ),
        ),
      ),
    ),
  ));
}
