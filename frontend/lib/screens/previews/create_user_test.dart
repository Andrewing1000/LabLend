import 'package:flutter/material.dart';
import 'package:frontend/screens/create_user.dart';

import '../../models/Session.dart';

Future<void> main() async {
  runApp(MaterialApp(
    home: CreateUserScreen(),
  ));


  var manager = SessionManager();
  Session session = await SessionManager().login("admin@example.com", "#123#AndresHinojosa#123");

}
