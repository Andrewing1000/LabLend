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
<<<<<<< HEAD
            Expanded(child: SearchPage()),

            //Footer(),

            //WelcomePage()
=======
            // Container(
            //   decoration: const BoxDecoration(
            //       image: DecorationImage(
            //           image: AssetImage('assets/images/place_holder.png'),
            //           fit: BoxFit.cover)),
            // ),
            // Container(
            //   color: Colors.black.withOpacity(0.45),
            // ),
            //Expanded(child: SearchPage()),

            //const Footer()
             const WelcomePage()
>>>>>>> Pruebas
          ],
        ),
      ),
    );
  }
}
