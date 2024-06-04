import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/widgets/create_item_form.dart';
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/widgets/notification.dart';

import 'PageBase.dart';

class CreateItemScreen extends PageBase{
  @override
  _CreateItemScreenState createState() => _CreateItemScreenState();

  @override
  Future<PageBase> onDispose() async {
    return this;
  }

  @override
  Future<PageBase> onSet() async {
    return this;
  }
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  bool _showNotification = false;
  String _notificationMessage = '';

  Future<void> _createItem(Item item, Uint8List? imageBytes) async {
    await item.create();

    if(imageBytes == null) return;
    await SessionManager.inventory.uploadImage(item, imageBytes, "png");
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
          slivers: [
            SliverList.list(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CreateItemForm(
                    onFormSubmit: _createItem,
                  ),
                ),
              ],
            ),
          ]
        );

  }
}
