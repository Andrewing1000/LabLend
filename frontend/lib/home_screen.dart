import 'package:flutter/material.dart';
import 'models/navbar.dart';
import 'models/customcardsection.dart'; // Asegúrate de que los widgets de tarjetas están aquí
import 'models/secciones.dart';
import 'models/login_button.dart'; // Importa el nuevo widget

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<NavItem> items = [
    NavItem(icon: Icons.home, title: "Inicio"),
    NavItem(icon: Icons.search, title: "Buscar"),
    NavItem(icon: Icons.telegram, title: "Contactanos"),
    NavItem(icon: Icons.help, title: "Ayuda"),
  ];

  void _onItemSelected(int index) {
    double targetPosition = index * 1000.0; // Ajustar según el contenido real
    _scrollController.animateTo(
      targetPosition,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
           Padding(
            padding: const EdgeInsets.only(right: 40.0), 
            child: LoginButton(),
          ),// Agregar el botón de login
        ],
      ),
      backgroundColor: Color.fromARGB(255, 77, 77, 77), // Fondo gris oscuro para todo el Scaffold
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
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Novedades",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CustomHorizontalCardSection(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Instrumentos",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CustomCardSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
