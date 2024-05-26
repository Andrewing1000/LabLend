import 'package:flutter/material.dart';
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/widgets/card_extended.dart';
import 'package:frontend/widgets/boton_agregar.dart';
import 'package:frontend/models/inventory.dart';
import 'package:frontend/widgets/notification.dart';

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
  bool _showNotification = false;
  String _notificationMessage = '';

  // Datos de prueba para las tarjetas
  final List<Map<String, String>> items = [
    {
      "imageUrl": "assets/images/place_holder.png",
      "equipmentName": "pru",
      "manufacturer": "PRUEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
      "model": "TDS MRD",
      "acquisitionDate": "Fecha",
      "location": "Lab",
    },
    
  ];

  void _createNewItem() {
    setState(() {
      inventory.createItem();
      items.add({
        "imageUrl": "assets/images/place_holder.png",
        "equipmentName": "Culo",
        "manufacturer": "Desconocido",
        "model": "N/A",
        "acquisitionDate": DateTime.now().toString(),
        "location": "Lab Desconocido",
      });
      _showNotification = true;
      _notificationMessage = "Agregacion de item";
    });

    // Ocultar la notificación automáticamente después de 3 segundos
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showNotification = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            BannerWidget(
              imageUrl: "assets/images/place_holder.png",
              title: "Coño",
              subtitle: "Fuckme",
              description: "AOLOREMMEMEMEMEMLOOLROLEOELLROERKEOKROSPJODNJFKSDHKJFHDLKJSHFILKJSDOLOROEOERLOERLEOROER.",
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
        ),
        // Mostrar la notificación si _showNotification es verdadero
        if (_showNotification)
          NotificationWidget(
            message: _notificationMessage,
            alignment: Alignment.bottomCenter,
          ),
      ],
    );
  }
}
