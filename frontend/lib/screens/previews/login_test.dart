import 'package:flutter/material.dart';
import 'package:frontend/themes/AppTheme.dart';
import '../LoginPage.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: LoginScreen(
        onSubmit: (a, b) async {
          // Simula la espera del servidor para ver el estado de carga.
          await Future.delayed(const Duration(seconds: 2));
        },
        onPasswordReset: () {},
        onClose: () {},
      ),
    ),
  ));
}
