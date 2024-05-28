import 'package:flutter/material.dart';

class AccionBoton extends StatefulWidget {
  final Function(String) onNotification; // Función de callback para enviar la notificación
  final String message; // Mensaje que se mostrará en la notificación
  final IconData icon; // Icono que se mostrará en el botón

  const AccionBoton({
    super.key,
    required this.onNotification,
    required this.message,
    required this.icon,
  });

  @override
  _AccionBotonState createState() => _AccionBotonState();
}

class _AccionBotonState extends State<AccionBoton> {
  // Método para enviar la notificación con el mensaje proporcionado
  void _sendNotification() {
    widget.onNotification(widget.message);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        icon: Icon(widget.icon), // Icono del botón
        iconSize: 30, // Tamaño del icono
        onPressed: _sendNotification, // Llamar al método para enviar la notificación al presionar el botón
      ),
    );
  }
}
