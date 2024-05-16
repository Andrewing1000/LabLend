import 'package:flutter/material.dart';
import 'models/navbar.dart';
import 'models/widgets.dart'; // Asegúrate de que los widgets de tarjetas están aquí

class HomeScreen extends StatelessWidget {
  final List<NavItem> items = [
    NavItem(icon: Icons.home, title: "Inicio"),
    NavItem(icon: Icons.search, title: "Busqueda"),
    NavItem(icon: Icons.notifications, title: "Contactanos"),
    NavItem(icon: Icons.account_circle, title: "Ayuda"),
  ];

  void _onItemSelected(int index) {
    // Manejar selección de ítems
    print("Ítem seleccionado: $index");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Navbar con Tarjetas")),
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
            flex: 8,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CustomCardWidget(),
                    SizedBox(height: 10),
                    CustomHorizontalCardWidget(),
                    SizedBox(height: 20),
                    CustomCardWidget(), 
                    SizedBox(height: 20),
                    CustomHorizontalCardWidget(),
                    CustomCardWidget(),
                    SizedBox(height: 10),
                    CustomHorizontalCardWidget(),
                    SizedBox(height: 20),
                    CustomCardWidget(), 
                    SizedBox(height: 20),
                    CustomHorizontalCardWidget(),
                                        CustomCardWidget(),
                    SizedBox(height: 10),
                    CustomHorizontalCardWidget(),
                    SizedBox(height: 20),
                    CustomCardWidget(), 
                    SizedBox(height: 20),
                    CustomHorizontalCardWidget(),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
