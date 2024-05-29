import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/widgets/edit_item_form.dart';
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/widgets/notification.dart';

class EditItemScreen extends StatefulWidget {
  final int itemId;

  const EditItemScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  Item? item;
  bool _showNotification = false;
  String _notificationMessage = '';

  @override
  void initState() {
    super.initState();
    _getItem(widget.itemId);
  }

  void _getItem(int itemId) async {
    // Obtener item por ID
    Item? fetchedItem = await SessionManager.inventory.getItemById(itemId);
    setState(() {
      item = fetchedItem;
    });
  }

  void _updateItem(Item newItem) {
    if (item != null) {
      item!.update(newItem);

      setState(() {
        _notificationMessage =
            "Item '${newItem.nombre}' actualizado con éxito.";
        _showNotification = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showNotification = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Editar Item'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          if (item != null)
            SingleChildScrollView(
              child: Column(
                children: [
                  BannerWidget(
                    imageUrl: "https://via.placeholder.com/150",
                    title: "Editar Item",
                    subtitle: "Modifique el formulario para actualizar el item",
                    description:
                        "Actualice los datos del item en el laboratorio.",
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: EditItemForm(
                      item: item!,
                      onFormSubmit: _updateItem,
                    ),
                  ),
                ],
              ),
            ),
          if (_showNotification)
            NotificationWidget(
              message: _notificationMessage,
            ),
        ],
      ),
    );
  }
}
