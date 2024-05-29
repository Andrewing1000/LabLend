import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/widgets/create_item_form.dart';
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/widgets/notification.dart';

class CreateItemScreen extends StatefulWidget {
  @override
  _CreateItemScreenState createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  bool _showNotification = false;
  String _notificationMessage = '';

  void _createItem(Item item) {
    item.create();

    setState(() {
      _notificationMessage = "Item '${item.nombre}' creado con éxito.";
      _showNotification = true;
    });

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showNotification = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Crear Item'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                BannerWidget(
                  imageUrl: "assets/images/place_holder.png",
                  title: "Crear Nuevo Item",
                  subtitle: "Complete el formulario para crear un nuevo item",
                  description:
                      "Ingrese los datos del nuevo item en el laboratorio.",
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CreateItemForm(
                    onFormSubmit: _createItem,
                  ),
                ),
              ],
            ),
          ),
          if (_showNotification)
            NotificationWidget(
              message: _notificationMessage,
              //alignment: Alignment.bottomCenter,
            ),
        ],
      ),
    );
  }
}
