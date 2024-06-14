import 'package:flutter/material.dart';
import 'package:frontend/widgets/footer_widget.dart';

void main() {
  runApp(const FooterTestApp());
}

class FooterTestApp extends StatelessWidget {
  const FooterTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FooterWidget(),
      ),
    );
  }
}
