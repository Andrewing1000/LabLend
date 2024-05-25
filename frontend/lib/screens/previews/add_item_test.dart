import 'package:flutter/material.dart';
import 'package:frontend/widgets/card.dart'; // Importar el widget CustomCard

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: AddItemsScreen(),
    ),
  ));
}

class AddItemsScreen extends StatelessWidget {
  // Datos de prueba para las tarjetas
  final List<Map<String, String>> items = [
    {"title": "Matraz", "subtitle": "Loren por favor, ya he dejado el alcohol"},
    {"title": "Reactivo", "subtitle": "Sulfato de cobre, altamente reactivo"},
    {"title": "Tubo de ensayo", "subtitle": "Útil para mezclas pequeñas"},
    {"title": "Bureta", "subtitle": "Medición precisa de volúmenes"},
    {"title": "Pipeta", "subtitle": "Transferencia precisa de líquidos"},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: CustomCard(
              title: item['title']!,
              subtitle: item['subtitle']!,
              onTap: () {
                // Acción a realizar cuando se hace clic en la tarjeta
                print("Card tapped: ${item['title']} - ${item['subtitle']}");
              },
            ),
          );
        },
      ),
    );
  }
}
