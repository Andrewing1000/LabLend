import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/main_frame.dart';
import 'package:frontend/screens/main_frame_vertical.dart';
import 'models/User.dart';
import 'screens/home_screen.dart';

Future<void> main() async {

  runApp(MyApp());
  var manager = SessionManager();
  Session session = await manager.login("admin@example.com", "#123#AndresHinojosa#123");

  //User admin2 = AdminUser(email: "admin4@gmail.com", name: "admini2");
  //admin2.create(password: "#123#AndresHinojosa#123");

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        body: VerticalMainFrame(),
      ),
    );
  }
}
