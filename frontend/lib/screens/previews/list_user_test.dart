import 'package:flutter/material.dart';
import 'package:frontend/screens/user_list_screen.dart';
import 'package:frontend/models/Session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var manager = SessionManager();
  Session session =
      await manager.login("admin@example.com", "#123#AndresHinojosa#123");

  runApp(MaterialApp(
    home: UserListPage(),
  ));
}
