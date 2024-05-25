import 'package:flutter/material.dart';
import 'package:frontend/widgets/card_extended.dart'; // Importar el widget CardExtended

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: CardExtendedTestScreen(),
    ),
  ));
}

class CardExtendedTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          CardExtended(
            imageUrl: "assets/images/place_holder.png",
            equipmentName: "Osciloscopio",
            manufacturer: "Tektronix",
            model: "TDS 2002B",
            acquisitionDate: "14 Sept 2023",
            location: "Lab 1",
          ),
          SizedBox(height: 20),
          CardExtended(
            imageUrl: "assets/images/place_holder.png",
            equipmentName: "Generador de Funciones",
            manufacturer: "Agilent",
            model: "33220A",
            acquisitionDate: "20 Oct 2022",
            location: "Lab 2",
          ),
        ],
      ),
    );
  }
}
