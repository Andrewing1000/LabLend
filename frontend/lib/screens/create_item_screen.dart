import 'package:flutter/material.dart';
import 'package:frontend/models/Item.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/create_user.dart' show PageHeader;
import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/create_item_form.dart';

import 'PageBase.dart';

class CreateItemScreen extends PageBase {
  CreateItemScreen({super.key});

  @override
  State<CreateItemScreen> createState() => _CreateItemScreenState();

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
  Future<void> _createItem(ItemFormData data) async {
    final name = data.name.trim();
    final description = data.description.trim();
    final serialNumber = data.serialNumber.trim();
    final quantity = data.quantity.trim();

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
    if (quantity.isEmpty) {
      SessionManager().errorNotification(error: "Se requiere la cantidad del equipo");
      return;
    }
    final brand = data.brand;
    if (brand == null) {
      SessionManager().errorNotification(error: "Se requiere especificar la marca");
      return;
    }

    final quantityInt = int.tryParse(quantity);
    if (quantityInt == null) {
      SessionManager().errorNotification(error: "La cantidad debe ser un número entero");
      return;
    }
    if (quantityInt < 1) {
      SessionManager().errorNotification(error: "La cantidad debe ser al menos 1");
      return;
    }

    final item = Item(
      nombre: name,
      description: description,
      link: data.link.trim(),
      quantity: quantityInt,
      marca: brand,
      categories: data.categories,
      quantityOnLoan: 0,
      serialNumber: serialNumber,
    );

    final pass = await SessionManager().confirmNotification(
        message: 'Se registrará el equipo "$name" con $quantityInt '
            '${quantityInt == 1 ? 'unidad' : 'unidades'}.');
    if (!pass) return;

    final res = await item.create();
    // Sin equipo creado no hay a qué subirle la imagen.
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
              const PageHeader(
                icon: Icons.add,
                title: 'Nuevo equipo',
                subtitle: 'Registre un equipo del laboratorio para que se pueda prestar.',
              ),
              CreateItemForm(
                onFormSubmit: _createItem,
                onCancel: () => widget.manager?.removePage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
