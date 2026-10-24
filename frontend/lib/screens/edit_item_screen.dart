import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/screens/create_user.dart' show PageHeader;
import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/item_details_form.dart';

import '../models/Item.dart';

class EditItemScreen extends PageBase {
  final Item item;
  EditItemScreen({super.key, required this.item}) : super(disposable: true);

  @override
  State<PageBase> createState() => EditItemScreenState();

  @override
  void onDispose() {
    return;
  }

  @override
  void onSet() {
    return;
  }
}

class EditItemScreenState extends State<EditItemScreen> {
  Future<void> _updateItem(ItemFormData data) async {
    final item = widget.item;
    final name = data.name.trim();
    final description = data.description.trim();
    final link = data.link.trim();
    final serialNumber = data.serialNumber.trim();
    final quantityText = data.quantity.trim();

    if (name.isEmpty) {
      SessionManager().errorNotification(error: "Se requiere el nombre del equipo");
      return;
    }
    if (description.isEmpty) {
      SessionManager().errorNotification(error: "Se requiere una descripción del equipo");
      return;
    }
    if (serialNumber.isEmpty) {
      SessionManager().errorNotification(error: "Se requiere el código de serie del equipo");
      return;
    }
    final quantity = int.tryParse(quantityText);
    if (quantity == null) {
      SessionManager().errorNotification(error: "La cantidad debe ser un número entero");
      return;
    }
    if (quantity < 1) {
      SessionManager().errorNotification(error: "La cantidad debe ser al menos 1");
      return;
    }
    if (quantity < item.quantityOnLoan) {
      SessionManager().errorNotification(
          error: "La cantidad no puede ser menor a las ${item.quantityOnLoan} unidades prestadas");
      return;
    }
    final brand = data.brand;
    if (brand == null) {
      SessionManager().errorNotification(error: "Se requiere especificar la marca");
      return;
    }

    final newItem = item.clone()
      ..nombre = name
      ..description = description
      ..link = link
      ..serialNumber = serialNumber
      ..quantity = quantity
      ..marca = brand
      ..categories = data.categories;

    // Un dato vacío y uno nulo cuentan como iguales.
    final noEdits = name == item.nombre &&
        description == (item.description ?? '') &&
        link == (item.link ?? '') &&
        serialNumber == (item.serialNumber ?? '') &&
        quantity == item.quantity &&
        brand.id == item.marca.id &&
        newItem.categories.length == item.categories.length &&
        newItem.categories.every((cat) => item.categories.any((orig) => orig.id == cat.id)) &&
        data.imageBytes == null;

    if (noEdits) {
      SessionManager().errorNotification(error: "No se registraron cambios");
      return;
    }

    final pass = await SessionManager()
        .confirmNotification(message: 'Se guardarán los cambios del equipo "${item.nombre}".');
    if (!pass) return;

    final res = await item.update(newItem);
    if (res == null) return;
    if (data.imageBytes != null) {
      await SessionManager.inventory
          .uploadImage(item, data.imageBytes!, data.imageExtension ?? 'png');
    }
    widget.manager?.removePage();
  }

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                icon: Icons.edit_outlined,
                title: 'Editar equipo',
                subtitle: 'Modifique los datos de ${widget.item.nombre}.',
              ),
              UpdateItemForm(
                item: widget.item,
                onFormSubmit: _updateItem,
                onCancel: () => widget.manager?.removePage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
