import 'package:flutter/material.dart';
import 'models/navbar.dart';
import 'models/secciones.dart'; // Asegúrate de que los widgets de tarjetas están aquí
import 'models/widgets.dart'; // Importa el nuevo widget

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<NavItem> items = [
    NavItem(icon: Icons.home, title: "Home"),
    NavItem(icon: Icons.search, title: "Search"),
    NavItem(icon: Icons.notifications, title: "Notifications"),
    NavItem(icon: Icons.account_circle, title: "Profile"),
  ];

  void _onItemSelected(int index) {
    double targetPosition = index * 600.0; // Ajustar según el contenido real
    _scrollController.animateTo(
      targetPosition,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Spotify-Style Navbar con SPA")),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: VerticalNavbar(
              items: items,
              onItemSelected: _onItemSelected,
            ),
          ),
          Expanded(
            flex: 9,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Container(child: CustomCardWidget()), // Altura ejemplo
                  Container(
                      child: CustomHorizontalCardSection()), // Sección nueva
                  Container(child: CustomCardWidget()),
                  Container(child: CustomHorizontalCardSection()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
