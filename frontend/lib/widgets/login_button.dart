import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // Maneja la selección de las opciones aquí
        print(value);
      },
      icon: const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: Colors.black),
      ),
      itemBuilder: (BuildContext context) {
        return {'Perfil', 'Cerrar sesión'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }
}
