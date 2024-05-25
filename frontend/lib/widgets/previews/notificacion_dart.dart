import 'package:flutter/material.dart';
import 'package:frontend/widgets/notification.dart';

void main() {
  runApp(NotificationTestApp());
}

class NotificationTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotificationTestScreen(),
    );
  }
}

class NotificationTestScreen extends StatefulWidget {
  @override
  _NotificationTestScreenState createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  bool _showNotification =
      false; // Estado para controlar la visibilidad de la notificación
  String _notificationMessage =
      "¡Notificación de prueba!"; // Mensaje de la notificación

  void _toggleNotification() {
    setState(() {
      _showNotification = !_showNotification;
    });

    // Ocultar la notificación automáticamente después de 3 segundos
    if (_showNotification) {
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showNotification = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: _toggleNotification,
                child: Text("Mostrar Notificación"),
              ),
            ),
            if (_showNotification)
              NotificationWidget(message: _notificationMessage),
          ],
        ),
      ),
    );
  }
}
