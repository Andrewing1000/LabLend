import 'package:frontend/screens/previews/preview_credentials.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/user_edit_screen.dart';
import '../../models/Session.dart';
import '../../models/User.dart';

Future<void> main() async {
  runApp(MaterialApp(
    home: EditUserScreen(
    user : AdminUser(
      email: "",
      nombres: "",
      apellidoPaterno: "",
      id: 1,
      isActive: true,
    )),
  ));

  var manager = SessionManager();
  Session session = await SessionManager()
      .login(previewUser, previewPassword);
}
