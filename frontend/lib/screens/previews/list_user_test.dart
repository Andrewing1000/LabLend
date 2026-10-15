import 'package:frontend/screens/previews/preview_credentials.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/user_list_screen.dart';
import 'package:frontend/models/Session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var manager = SessionManager();
  Session session =
      await manager.login(previewEmail, previewPassword);

  runApp(const MaterialApp(
    home: UserListPage(),
  ));
}
