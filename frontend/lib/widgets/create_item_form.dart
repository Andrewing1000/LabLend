import 'package:flutter/material.dart';
import 'package:frontend/widgets/item_details_form.dart';

export 'package:frontend/widgets/item_details_form.dart' show ItemFormData;

/// Formulario para registrar un equipo nuevo. Comparte campos, secciones e
/// imagen con el de edición (ItemForm).
class CreateItemForm extends StatelessWidget {
  final Future<void> Function(ItemFormData data) onFormSubmit;
  final VoidCallback? onCancel;

  const CreateItemForm({super.key, required this.onFormSubmit, this.onCancel});

  @override
  Widget build(BuildContext context) =>
      ItemForm(onFormSubmit: onFormSubmit, onCancel: onCancel);
}
