import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/widgets/item_details_form.dart';
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/widgets/notification.dart';

class ItemDetailsScreen extends StatefulWidget {
  final int itemId;

  const ItemDetailsScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  _ItemDetailsScreenState createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  Item? item;
  bool _showNotification = false;
  String _notificationMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchItemDetails();
  }

  void _fetchItemDetails() async {
    Item? fetchedItem =
        await SessionManager.inventory.getItemById(widget.itemId);
    setState(() {
      item = fetchedItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Detalles del Item'),
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
                    title: item!.nombre,
                    subtitle: item!.marca.marca,
                    description: item!.description ?? "No description",
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ItemDetailsForm(
                      item: item!,
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
