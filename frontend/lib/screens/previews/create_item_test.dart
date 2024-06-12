import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/screens/create_item_screen.dart';
import 'package:frontend/models/UserManager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Item Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CreateItemScreenTest(),
    );
  }
}

class CreateItemScreenTest extends StatefulWidget {
  @override
  _CreateItemScreenTestState createState() => _CreateItemScreenTestState();
}

class _CreateItemScreenTestState extends State<CreateItemScreenTest> {
  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    // Inicializa la sesión, asegúrate de que el SessionManager esté configurado correctamente
    var manager = SessionManager();
    Session session = await SessionManager()
        .login("admin@example.com", "#123#AndresHinojosa#123");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Item Test'),
      ),
      body: CreateItemScreen(),
    );
  }
}
