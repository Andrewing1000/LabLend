import 'package:flutter/material.dart';
import 'package:frontend/screens/edit_item_screen.dart';

import '../../models/Session.dart';

Future<void> main() async {
  runApp(MaterialApp(
    home: EditItemScreen(itemId: 1),
  ));

  var manager = SessionManager();
  Session session = await SessionManager()
      .login("admin@example.com", "#123#AndresHinojosa#123");
}
