import 'package:flutter/material.dart';
import 'package:frontend/screens/edit_item_screen.dart';
import 'package:frontend/models/Session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de la sesión para autenticación
  var manager = SessionManager();
  Session session = await SessionManager()
      .login("admin@example.com", "#123#AndresHinojosa#123");

  runApp(MaterialApp(
    home: ItemDetailsScreen(),
  ));
}
