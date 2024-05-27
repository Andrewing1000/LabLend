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

  //var admin = AdminUser(name: "Admin3", email: "admin3@example.com", isActive: true);
  //admin.create(password: "#123#AndresHinojosa#123");
  List<User> list = await session.getUserList();

  var newUser = User.clone(session.user);
  newUser.name = "Admin";
  session.user.update(newUser: newUser);
  // list.forEach((e){
  //   print(e.toString());
  // });



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
