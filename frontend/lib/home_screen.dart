import 'package:flutter/material.dart';
import 'models/navbar.dart';

class HomeScreen extends StatelessWidget {
  final List<NavItem> items = [
    NavItem(icon: Icons.home, title: "inicio"),
    NavItem(icon: Icons.search, title: "Buscar"),
    NavItem(icon: Icons.telegram, title: "Contactanos"),
    NavItem(icon: Icons.help, title: "Ayuda"),
  ];

  void _onItemSelected(int index) {
    // Handle item selection, possibly using a setState if in a StatefulWidget
    print("Selected: $index");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Spotify-Style Navbar")),
      body: VerticalNavbar(
        items: items,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
