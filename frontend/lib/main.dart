// lib/main.dart

import 'package:flutter/material.dart';
import 'models/navbar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Vertical Navbar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.home, title: 'Inicio'),
    NavItem(icon: Icons.search, title: 'Busqueda'),
    NavItem(icon: Icons.telegram_sharp, title: 'Contactos'),
    NavItem(icon: Icons.help, title: 'Ayuda'),
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagina Main'),
      ),
      body: Row(
        children: [
          Container(
            width: 200,
            color: Colors.white,
            child: VerticalNavbar(
              items: _navItems,
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemSelected,
            ),
          ),
          Expanded(
            child: Center(
              child: Text('Selected: ${_navItems[_selectedIndex].title}'),
            ),
          ),
        ],
      ),
    );
  }
}
