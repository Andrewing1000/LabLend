import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // Maneja la selección de las opciones aquí
        print(value);
      },
      icon: CircleAvatar(
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
