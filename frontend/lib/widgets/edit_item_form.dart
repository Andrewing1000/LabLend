import 'package:flutter/material.dart';
import 'package:frontend/models/Item.dart';
import 'package:frontend/widgets/item_details_form.dart';

/// Formulario de edición que entrega el equipo ya armado, sin la imagen.
/// Antes mostraba marcas y categorías de ejemplo; ahora usa las del
/// servidor a través de ItemForm. La pantalla de edición usa
/// UpdateItemForm, que además entrega la imagen nueva.
class EditItemForm extends StatelessWidget {
  final Item item;
  final Function(Item) onFormSubmit;
  final VoidCallback? onCancel;

  const EditItemForm({
    super.key,
    required this.item,
    required this.onFormSubmit,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ItemForm(
      item: item,
      onCancel: onCancel,
      onFormSubmit: (data) async {
        final edited = item.clone()
          ..nombre = data.name.trim()
          ..description = data.description.trim()
          ..link = data.link.trim()
          ..serialNumber = data.serialNumber.trim()
          ..quantity = int.tryParse(data.quantity.trim()) ?? item.quantity
          ..marca = data.brand ?? item.marca
          ..categories = data.categories;
        await onFormSubmit(edited);
      },
    );
  }
}
