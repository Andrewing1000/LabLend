import 'package:flutter/material.dart';

import '../widgets/string_field.dart';


class RecuperarContrasenaScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  RecuperarContrasenaScreen({super.key});

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
                controller: emailController,
                hintText: "email",
                width: 300, // Ancho del campo de texto
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Validar el campo
                  if (emailController.text.isNotEmpty) {
                    print("Correo Electrónico: ${emailController.text}");
                    // Lógica para enviar el correo de recuperación
                  } else {
                    print("El campo es obligatorio.");
                  }
                },
                child: const Text("Recuperar"),
              ),
            ],
          ),
        ),
    );
  }
}
