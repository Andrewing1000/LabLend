import 'package:flutter/material.dart';
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/widgets/card_extended.dart';
import 'package:frontend/widgets/boton_agregar.dart';
import 'package:frontend/models/inventory.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: AddItemsScreen(),
    ),
  ));
}

class AddItemsScreen extends StatefulWidget {
  @override
  _AddItemsScreenState createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  final Inventory inventory = Inventory();

  // Datos de prueba para las tarjetas
  final List<Map<String, String>> items = [
    {
      "imageUrl": "assets/images/place_holder.png",
      "equipmentName": "menos lorem",
      "manufacturer": "culo",
      "model": "TDS 2002B",
      "acquisitionDate": "14 Sept 2023",
      "location": "Lab 1",
    },
    {
      "imageUrl": "assets/images/place_holder.png",
      "equipmentName": "menos lorem",
      "manufacturer": "culo mas",
      "model": "TDS 2002B",
      "acquisitionDate": "14 Sept 2023",
      "location": "Lab 1",
    },
    
  ];

  void _createNewItem() {
    setState(() {
      inventory.createItem();
      items.add({
        "imageUrl": "assets/images/place_holder.png",
        "equipmentName": "Nuevo Item",
        "manufacturer": "Desconocido",
        "model": "fuckj",
        "acquisitionDate": DateTime.now().toString(),
        "location": "Lab Desconocidoaa",
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BannerWidget(
          imageUrl: "assets/images/place_holder.png",
          title: "froga",
          subtitle: "menos lorem",
          description: "fuck",
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
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: BotonAgregar(
              onPressed: _createNewItem,
            ),
          ),
        ),
      ],
    );
  }
}
