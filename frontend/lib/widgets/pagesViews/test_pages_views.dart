import 'package:flutter/material.dart';
import 'package:frontend/widgets/pagesViews/footer_page.dart';
import 'package:frontend/widgets/pagesViews/search_page.dart';
import 'package:frontend/widgets/pagesViews/welcome_page.dart';
//import 'package:frontend/widgets/pagesViews/welcome_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            Expanded(child: SearchPage()),

            //Footer(),

            //WelcomePage()
          ],
        ),
      ),
    );
  }
}
