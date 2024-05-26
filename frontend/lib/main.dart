import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'models/Request.dart';
import 'package:frontend/settings.dart'; // Ensure this file exists and contains 'serverURL'


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  SessionManager manager = SessionManager();

  await manager.login("admin@example.com", "#123#AndresHinojosa#123");
  manager.logOut();

  // runApp(const MyApp());
}
