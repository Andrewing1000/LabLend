import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/widgets/item_details_form.dart';
import 'package:frontend/widgets/notification.dart';

class ItemDetailsScreen extends StatefulWidget {
  final int itemId;

  const ItemDetailsScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  _ItemDetailsScreenState createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  Item? _item;
  bool _showNotification = false;
  String _notificationMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchItem();
  }

  Future<void> _fetchItem() async {
    try {
      Item? fetchedItem =
          await SessionManager.inventory.getItemById(widget.itemId);
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
            child: _item == null
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ItemDetailsForm(item: _item!),
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
