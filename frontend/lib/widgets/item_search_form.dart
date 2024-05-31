import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/widgets/item_details_form.dart';
import 'package:frontend/widgets/notification.dart';

class ItemSearchForm extends StatefulWidget {
  @override
  _ItemSearchFormState createState() => _ItemSearchFormState();
}

class _ItemSearchFormState extends State<ItemSearchForm> {
  final TextEditingController _idController = TextEditingController();
  Item? _item;
  bool _showNotification = false;
  String _notificationMessage = '';

  Future<void> _searchItem() async {
    try {
      int id = int.parse(_idController.text);
      Item? fetchedItem = await SessionManager.inventory.getItemById(id);
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
        title: Text('Buscar y Editar Ítem'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: _idController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[900],
                      hintText: 'Ingrese el ID del Ítem',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _searchItem,
                  child: Text('Buscar Ítem'),
                ),
                if (_item != null)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ItemDetailsForm(item: _item!),
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
