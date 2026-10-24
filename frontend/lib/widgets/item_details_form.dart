import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Item.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/equipment_card.dart';
import 'package:frontend/widgets/string_field.dart';
import 'package:frontend/widgets/user_form.dart';

/// Lo que el formulario de equipo entrega al guardar. Los textos van tal
/// como se escribieron (sin recortar): la pantalla los valida.
class ItemFormData {
  final String name;
  final String description;
  final String link;
  final String serialNumber;
  final String quantity;
  final Brand? brand;
  final List<Category> categories;

  /// Imagen nueva elegida, o null si no se eligió ninguna.
  final Uint8List? imageBytes;

  /// Extensión de la imagen nueva ('jpeg' o 'png').
  final String? imageExtension;

  const ItemFormData({
    required this.name,
    required this.description,
    required this.link,
    required this.serialNumber,
    required this.quantity,
    required this.brand,
    required this.categories,
    this.imageBytes,
    this.imageExtension,
  });
}

/// Formulario de equipo, para registrarlo o editarlo. Va por secciones:
/// datos, clasificación (marca y categorías) e imagen.
class ItemForm extends StatefulWidget {
  /// Equipo a editar, o null para registrar uno nuevo.
  final Item? item;
  final Future<void> Function(ItemFormData data) onFormSubmit;
  final VoidCallback? onCancel;

  const ItemForm({
    super.key,
    this.item,
    required this.onFormSubmit,
    this.onCancel,
  });

  @override
  State<ItemForm> createState() => _ItemFormState();
}

/// Formulario para editar un equipo existente.
class UpdateItemForm extends StatelessWidget {
  final Item item;
  final Future<void> Function(ItemFormData data) onFormSubmit;
  final VoidCallback? onCancel;

  const UpdateItemForm({
    super.key,
    required this.item,
    required this.onFormSubmit,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) =>
      ItemForm(item: item, onFormSubmit: onFormSubmit, onCancel: onCancel);
}

class _ItemFormState extends State<ItemForm> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  final serialNumberController = TextEditingController();
  final quantityController = TextEditingController();

  List<Brand> brands = [];
  List<Category> categories = [];
  bool loadingOptions = true;

  int? selectedBrandId;
  final Set<int> selectedCategoryIds = {};

  Uint8List? imageBytes;
  String? imageExtension;
  bool saving = false;

  bool get updateMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      nameController.text = item.nombre;
      descriptionController.text = item.description ?? '';
      linkController.text = item.link ?? '';
      serialNumberController.text = item.serialNumber ?? '';
      quantityController.text = item.quantity.toString();
      selectedBrandId = item.marca.id;
      selectedCategoryIds.addAll(item.categories.map((c) => c.id));
    }
    _loadOptions();
  }

  /// Marcas y categorías se piden una sola vez, no en cada redibujo.
  Future<void> _loadOptions() async {
    setState(() => loadingOptions = true);
    final results = await Future.wait([
      SessionManager.inventory.getBrands(),
      SessionManager.inventory.getCategories(),
    ]);
    if (!mounted) return;
    setState(() {
      brands = (results[0] as List<Brand>)
        ..sort((a, b) => a.marca.toLowerCase().compareTo(b.marca.toLowerCase()));
      categories = (results[1] as List<Category>)
        ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
      // Una marca que ya no existe no puede quedar elegida en la lista.
      if (!brands.any((b) => b.id == selectedBrandId)) selectedBrandId = null;
      loadingOptions = false;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    serialNumberController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      // Sin esto, fuera de la web los bytes llegan vacíos.
      withData: true,
    );
    final file = result?.files.single;
    if (file == null || file.bytes == null || !mounted) return;
    final ext = (file.extension ?? 'png').toLowerCase();
    setState(() {
      imageBytes = file.bytes;
      // El servidor arma el tipo como image/<extensión>: "jpg" no es válido.
      imageExtension = ext == 'jpg' ? 'jpeg' : ext;
    });
  }

  void _removeImage() => setState(() {
        imageBytes = null;
        imageExtension = null;
      });

  Future<void> _submit() async {
    if (saving) return;
    setState(() => saving = true);
    try {
      final brand = brands.where((b) => b.id == selectedBrandId).firstOrNull;
      await widget.onFormSubmit(ItemFormData(
        name: nameController.text,
        description: descriptionController.text,
        link: linkController.text,
        serialNumber: serialNumberController.text,
        quantity: quantityController.text,
        // Si las listas no cargaron, se conserva lo que ya tenía el equipo.
        brand: brand ?? (brands.isEmpty ? widget.item?.marca : null),
        categories: categories.isEmpty && updateMode
            ? widget.item!.categories
            : categories.where((c) => selectedCategoryIds.contains(c.id)).toList(),
        imageBytes: imageBytes,
        imageExtension: imageExtension,
      ));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= AppBreakpoints.compact;

    Widget pair(Widget a, Widget b) => wide
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: a),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: b),
          ])
        : Column(children: [a, const SizedBox(height: AppSpacing.lg), b]);

    final item = widget.item;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormSection(
          title: 'Datos del equipo',
          children: [
            StringField(
              controller: nameController,
              hintText: 'Osciloscopio digital',
              labelText: 'Nombre',
              width: double.infinity,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: descriptionController,
              minLines: 3,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Para qué sirve y qué incluye',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            pair(
              StringField(
                controller: serialNumberController,
                hintText: 'SN-000123',
                labelText: 'Código de serie',
                width: double.infinity,
                textInputAction: TextInputAction.next,
              ),
              StringField(
                controller: quantityController,
                hintText: '1',
                labelText: 'Cantidad',
                digitsOnly: true,
                width: double.infinity,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            StringField(
              required: false,
              controller: linkController,
              hintText: 'https://',
              labelText: 'Enlace (opcional)',
              width: double.infinity,
            ),
            if (item != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                item.quantityOnLoan > 0
                    ? 'Hay ${item.quantityOnLoan} '
                        '${item.quantityOnLoan == 1 ? 'unidad prestada' : 'unidades prestadas'}: '
                        'la cantidad no puede ser menor.'
                    : 'No hay unidades prestadas en este momento.',
                style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
        FormSection(
          title: 'Clasificación',
          children: loadingOptions
              ? [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator(semanticsLabel: 'Cargando')),
                  ),
                ]
              : _classification(),
        ),
        FormSection(
          title: 'Imagen',
          children: [
            _ImageArea(
              bytes: imageBytes,
              existingUrl: item?.imagePath,
              enabled: !saving,
              onPick: _pickImage,
              onRemove: _removeImage,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            if (widget.onCancel != null)
              OutlinedButton(
                onPressed: saving ? null : widget.onCancel,
                style: OutlinedButton.styleFrom(minimumSize: const Size(140, 48)),
                child: const Text('Cancelar'),
              ),
            FilledButton(
              onPressed: saving ? null : _submit,
              style: FilledButton.styleFrom(minimumSize: const Size(180, 48)),
              child: saving
                  ? Row(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text('Guardando'),
                    ])
                  : Text(updateMode ? 'Guardar cambios' : 'Registrar equipo'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  List<Widget> _classification() {
    final hint = TextStyle(fontSize: 12, height: 1.5, color: AppColors.textMuted);
    return [
      if (brands.isEmpty)
        Text(
          'No hay marcas registradas. Agréguelas en Marcas y categorías.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        )
      else
        DropdownButtonFormField<int>(
          initialValue: selectedBrandId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Marca'),
          dropdownColor: AppColors.surfaceHigh,
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          items: [
            for (final brand in brands)
              DropdownMenuItem<int>(value: brand.id, child: Text(brand.marca)),
          ],
          onChanged: saving ? null : (id) => setState(() => selectedBrandId = id),
        ),
      const SizedBox(height: AppSpacing.xl),
      Text('Categorías',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: AppSpacing.md),
      if (categories.isEmpty)
        Text('No hay categorías registradas. Agréguelas en Marcas y categorías.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
      else ...[
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final category in categories)
              _CheckOption(
                label: category.nombre,
                selected: selectedCategoryIds.contains(category.id),
                onTap: saving
                    ? null
                    : () => setState(() {
                          if (!selectedCategoryIds.remove(category.id)) {
                            selectedCategoryIds.add(category.id);
                          }
                        }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Puede elegir varias o ninguna.', style: hint),
      ],
    ];
  }
}

/// Opción marcable de una lista (categorías): casilla y texto, con borde
/// fino; sin colores de relleno.
class _CheckOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _CheckOption({required this.label, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: selected ? AppColors.textSecondary : AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 18,
                color: selected ? AppColors.textPrimary : AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Imagen del equipo: vista previa sobre fondo blanco (como en el resto de
/// la aplicación) o un área vacía para agregarla.
class _ImageArea extends StatelessWidget {
  final Uint8List? bytes;
  final String? existingUrl;
  final bool enabled;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ImageArea({
    required this.bytes,
    required this.existingUrl,
    required this.enabled,
    required this.onPick,
    required this.onRemove,
  });

  static const Color _photoBackground = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final hasExisting = existingUrl != null && existingUrl!.isNotEmpty;
    final note = TextStyle(fontSize: 12, height: 1.5, color: AppColors.textMuted);

    if (bytes == null && !hasExisting) {
      return Semantics(
        button: true,
        label: 'Agregar imagen',
        child: InkWell(
          onTap: enabled ? onPick : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Agregar imagen',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Text('JPG o PNG. Se recomienda el equipo sobre fondo claro.', style: note),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 240,
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: _photoBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: bytes != null
              ? Image.memory(bytes!, fit: BoxFit.contain)
              : EquipmentImage(url: existingUrl, fit: BoxFit.contain),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          children: [
            TextButton(
              onPressed: enabled ? onPick : null,
              child: const Text('Cambiar imagen'),
            ),
            if (bytes != null)
              TextButton(
                onPressed: enabled ? onRemove : null,
                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                child: const Text('Quitar imagen'),
              ),
          ],
        ),
        if (hasExisting)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: Text(
              bytes != null
                  ? 'La nueva imagen reemplaza a la actual al guardar los cambios.'
                  : 'Imagen actual del equipo. Se conserva si no elige otra.',
              style: note,
            ),
          ),
      ],
    );
  }
}
