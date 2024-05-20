import 'package:flutter/material.dart';
import '/widgets/password_creation_field.dart'; 

void main() {
  final TextEditingController passwordController = TextEditingController(); // Controlador para el campo de texto

  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Espaciado alrededor del contenido
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Widget PasswordCreationField con estética Spotify
              PasswordCreationField(
                controller: passwordController,
                hintText: "Create your password",
                width: 300, // Ancho del campo de texto
              ),
              SizedBox(height: 20),
              // Botón para imprimir la contraseña en consola
              ElevatedButton(
                onPressed: () {
                  print("Contraseña Boton: ${passwordController.text}");
                },
                child: Text("Show Password"),
              ),
            ],
          ),
        ),
      ),
    ),
  ));
}
