import 'package:flutter/material.dart';
import 'package:frontend/widgets/banner.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: BannerTestScreen(),
    ),
  ));
}

class BannerTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: BannerWidget(
        imageUrl: "assets/images/place_holder.png",
        title: "Frogaa",
        subtitle: "Frog",
        description: "nose que hise mierda",
        baseColor: Colors.purple, 
      ),
    );
  }
}
