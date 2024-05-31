import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/widgets/item_details_form.dart';
import 'package:frontend/widgets/notification.dart';
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/widgets/string_field.dart';

class ItemDetailsScreen extends StatefulWidget {
  @override
  _ItemDetailsScreenState createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  Item? _item;
  bool _showNotification = false;
  String _notificationMessage = '';
  final TextEditingController _idController = TextEditingController();

  Future<void> _fetchItem() async {
    final itemId = int.tryParse(_idController.text);
    if (itemId == null) {
      setState(() {
        _notificationMessage = 'ID inválido';
        _showNotification = true;
      });
      return;
    }

    try {
      Item? fetchedItem = await SessionManager.inventory.getItemById(itemId);
      setState(() {
        _item = fetchedItem;
        if (_item == null) {
          _notificationMessage = 'Ítem no encontrado';
          _showNotification = true;
        }
      });
    } catch (e) {
      setState(() {
        _notificationMessage = 'Error al buscar el ítem';
        _showNotification = true;
      });
    }

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
        title: Text('Detalles del Ítem'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                if (_item == null)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        StringField(
                          controller: _idController,
                          hintText: 'Ingrese el ID del Ítem',
                          width: MediaQuery.of(context).size.width * 0.8,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchItem,
                          child: Text('Buscar Ítem'),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      BannerWidget(
                        imageUrl: 'assets/images/place_holder.png',
                        title: _item!.nombre,
                        subtitle: _item!.marca.marca,
                        description: _item!.description ?? '',
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ItemDetailsForm(item: _item!),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (_showNotification)
            NotificationWidget(
              message: _notificationMessage,
              // alignment: Alignment.bottomCenter,
            ),
        ],
      ),
    );
  }
}
