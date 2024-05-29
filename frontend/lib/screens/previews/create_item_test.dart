import 'package:flutter/material.dart';
import 'package:frontend/screens/create_item_screen.dart';

import '../../models/Session.dart';

Future<void> main() async {
  runApp(MaterialApp(
    home: CreateItemScreen(),
  ));

  var manager = SessionManager();
  Session session = await SessionManager()
      .login("admin@example.com", "#123#AndresHinojosa#123");
}
