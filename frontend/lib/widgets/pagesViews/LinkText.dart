import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Linktext extends StatelessWidget {
  final String text;
  final String url;
  const Linktext({super.key, required this.text, required this.url});
  Future<void> _launchURL() async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchURL,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.amber,
          fontSize: 19,
        ),
      ),
    );
  }
}
