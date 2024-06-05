import 'package:flutter/material.dart';
import 'package:frontend/widgets/footer_widget.dart';

void main() {
  runApp(FooterTestApp());
}

class FooterTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FooterWidget(),
      ),
    );
  }
}
