import 'package:flutter/material.dart';
import 'package:frontend/screens/user_edit_screen.dart';
import '../../models/Session.dart';

Future<void> main() async {
  runApp(MaterialApp(
    home: EditUserScreen(),
  ));

  var manager = SessionManager();
  Session session = await SessionManager()
      .login("admin@example.com", "#123#AndresHinojosa#123");
}
