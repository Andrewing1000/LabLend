import 'package:flutter/material.dart';
import 'package:frontend/widgets/pagesViews/welcome_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/images/place_holder.png'),
                fit: BoxFit.cover
                )
              ),
            ),
            WelcomePage()
          ],
        ),
      ),
    );
  }
}
