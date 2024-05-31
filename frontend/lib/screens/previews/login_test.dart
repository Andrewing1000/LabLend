import 'package:flutter/material.dart';
import '../LoginPage.dart';

void main() {
  runApp(MaterialApp(
    home: LoginScreen(
      onSubmit: (a, b) {print("Se loggeo");}, onPasswordReset: () {  },
    ),
  ));
}

