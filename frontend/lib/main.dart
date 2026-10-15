import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/themes/AppTheme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
          body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: SessionManager()),
        ],
        child: Consumer<SessionManager>(
          builder: (context, sessionManager, child) {
            return  SessionManager.mainFrame;
          },
        ),
      )),
    );
  }
}
