import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/models/Item.dart';
import 'package:frontend/widgets/create_item_form.dart';
import 'package:frontend/widgets/banner.dart';

import 'PageBase.dart';

class CreateItemScreen extends PageBase{
  CreateItemScreen({super.key});

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
  final bool _showNotification = false;
  final String _notificationMessage = '';

  Future<void> _createItem(
      {
      required String name,
      required String description,
      required String link,
      required String serialNumber,
      required String quantity,
      Brand? brand,
      required List<Category> categories,
      Uint8List? imageBytes,
      }) async {

    if(name.isEmpty){
      SessionManager().errorNotification(error: "Se requiere el nombre del Item");
      return;
    }
    if(description.isEmpty){
      SessionManager().errorNotification(error: "Se requiere una descripción del Item");
      return;
    }
    if(serialNumber.isEmpty){
      SessionManager().errorNotification(error: "Se requiere el código serial del Item");
      return;
    }
    if(quantity.isEmpty){
      SessionManager().errorNotification(error: "Se requiere la cantidad del Item");
      return;
    }
    if(brand == null){
      SessionManager().errorNotification(error: "Se requiere especificar la marca");
      return;
    }

    int quantityInt = 0;
    try{
      quantityInt = int.parse(quantity);
    }catch(e){
      SessionManager().errorNotification(error: "La cantidad debe ser un entero");
      return;
    }

    Item item = Item(
      nombre: name,
      description: description,
      link: link,
      quantity: quantityInt,
      marca: brand,
      categories: categories,
      quantityOnLoan: 0,
      serialNumber: serialNumber,
    );


    final pass = await SessionManager().confirmNotification(message: "Confirmar la creación de item");
    var res = await item.create();
    if(imageBytes != null){
      await SessionManager.inventory.uploadImage(item, imageBytes, 'png');
    }
    if (res != null) {
      widget.manager?.removePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
          slivers: [
            SliverList.list(
              children: [
                const BannerWidget(
                  imageUrl: null,
                  title: "Registrar item",
                  subtitle: "",
                  description: "",
                ),
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
