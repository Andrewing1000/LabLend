import 'package:flutter/material.dart';
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/widgets/card_extended.dart';

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
    {
      "imageUrl": "assets/images/place_holder.png",
      "equipmentName": "Osciloscopio",
      "manufacturer": "froga",
      "model": "TDS 2002B",
      "acquisitionDate": "14 Sept 2023",
      "location": "Lab 1",
    },
    {
      "imageUrl": "assets/images/place_holder.png",
      "equipmentName": "Generador de Funciones",
      "manufacturer": "frago",
      "model": "33220A",
      "acquisitionDate": "20 Oct 2022",
      "location": "Lab 2",
    },

  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BannerWidget(
          imageUrl: "assets/images/place_holder.png",
          title: "Fuckme",
          subtitle: "culoos",
          description: "No que hise mierda ",
          baseColor: Colors.green, // Color base para el degradado
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: CardExtended(
                    imageUrl: item['imageUrl']!,
                    equipmentName: item['equipmentName']!,
                    manufacturer: item['manufacturer']!,
                    model: item['model']!,
                    acquisitionDate: item['acquisitionDate']!,
                    location: item['location']!,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
