import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/category_brand_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var manager = SessionManager();
  Session session = await SessionManager()
      .login("admin@example.com", "#123#AndresHinojosa#123");

  runApp(MyApp(session: session));
}

class MyApp extends StatelessWidget {
  final Session session;

  MyApp({required this.session});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Category and Brand Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CategoryBrandScreen(),
    );
  }
}
