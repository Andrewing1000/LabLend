import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Map Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapPage(),
    );
  }
}

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Map Example'),
      ),
      body: Center(
        child: Container(
          height: 450,
          child: WebView(
            initialUrl:
                'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d407.45002657332714!2d-68.11182575007226!3d-16.522846387804776!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x915f21ff12753ef1%3A0x61fc63834bdc032b!2s%C3%81gora%20U.C.B.!5e0!3m2!1ses-419!2sbo!4v1717591280906!5m2!1ses-419!2sbo',
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
      ),
    );
  }
}
