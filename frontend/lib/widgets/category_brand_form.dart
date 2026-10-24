import 'package:flutter/material.dart';
import 'package:frontend/models/Item.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/state_message.dart';
import 'package:frontend/widgets/user_form.dart';

/// Listas de categorías y marcas: cada una con su campo para agregar y la
/// opción de eliminar en cada fila.
class CategoryBrandForm extends StatefulWidget {
  const CategoryBrandForm({super.key});

  @override
  State<CategoryBrandForm> createState() => _CategoryBrandFormState();
}

class _CategoryBrandFormState extends State<CategoryBrandForm> {
  final _categoryNameController = TextEditingController();
  final _categoryDescriptionController = TextEditingController();
  final _brandNameController = TextEditingController();

  List<Category> _categories = [];
  List<Brand> _brands = [];
  bool _loadingCategories = true;
  bool _loadingBrands = true;
  bool _savingCategory = false;
  bool _savingBrand = false;

  /// Filas que se están eliminando, para no repetir la acción.
  final Set<int> _deletingCategories = {};
  final Set<int> _deletingBrands = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadBrands();
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _categoryDescriptionController.dispose();
    _brandNameController.dispose();
    super.dispose();
  }

  static int _byText(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    final categories = await SessionManager.inventory.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories..sort((a, b) => _byText(a.nombre, b.nombre));
      _loadingCategories = false;
    });
  }

  Future<void> _loadBrands() async {
    setState(() => _loadingBrands = true);
    final brands = await SessionManager.inventory.getBrands();
    if (!mounted) return;
    setState(() {
      _brands = brands..sort((a, b) => _byText(a.marca, b.marca));
      _loadingBrands = false;
    });
  }

  Future<void> _createCategory() async {
    if (_savingCategory) return;
    final name = _categoryNameController.text.trim();
    if (name.isEmpty) {
      SessionManager().errorNotification(error: "Escriba el nombre de la categoría");
      return;
    }
    if (_categories.any((c) => c.nombre.toLowerCase() == name.toLowerCase())) {
      SessionManager().errorNotification(error: 'Ya existe la categoría "$name"');
      return;
    }
    setState(() => _savingCategory = true);
    final created = await SessionManager.inventory.createCategory(Category(
      id: 0,
      nombre: name,
      description: _categoryDescriptionController.text.trim(),
    ));
    if (!mounted) return;
    setState(() => _savingCategory = false);
    if (created != null) {
      _categoryNameController.clear();
      _categoryDescriptionController.clear();
      await _loadCategories();
    }
  }

  Future<void> _createBrand() async {
    if (_savingBrand) return;
    final name = _brandNameController.text.trim();
    if (name.isEmpty) {
      SessionManager().errorNotification(error: "Escriba el nombre de la marca");
      return;
    }
    if (_brands.any((b) => b.marca.toLowerCase() == name.toLowerCase())) {
      SessionManager().errorNotification(error: 'Ya existe la marca "$name"');
      return;
    }
    setState(() => _savingBrand = true);
    final created = await SessionManager.inventory.createBrand(Brand(id: 0, marca: name));
    if (!mounted) return;
    setState(() => _savingBrand = false);
    if (created != null) {
      _brandNameController.clear();
      await _loadBrands();
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await SessionManager().confirmNotification(
        message: 'La categoría "${category.nombre}" será eliminada.');
    if (!confirmed || !mounted) return;
    setState(() => _deletingCategories.add(category.id));
    final deleted = await SessionManager.inventory.deleteCategory(category);
    if (!mounted) return;
    setState(() => _deletingCategories.remove(category.id));
    if (deleted) await _loadCategories();
  }

  Future<void> _deleteBrand(Brand brand) async {
    final confirmed = await SessionManager().confirmNotification(
        message: 'La marca "${brand.marca}" será eliminada.');
    if (!confirmed || !mounted) return;
    setState(() => _deletingBrands.add(brand.id));
    final deleted = await SessionManager.inventory.deleteBrand(brand);
    if (!mounted) return;
    setState(() => _deletingBrands.remove(brand.id));
    if (deleted) await _loadBrands();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoriesSection();
    final brands = _brandsSection();

    if (AppBreakpoints.isWide(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: categories),
          const SizedBox(width: AppSpacing.xxl),
          Expanded(child: brands),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [categories, brands],
    );
  }

  /// Los servicios devuelven una lista vacía también cuando falla la
  /// conexión: en ese caso se avisa eso, con la opción de reintentar.
  Widget _emptyOrOffline({
    required String title,
    required String message,
    required IconData icon,
    required VoidCallback onRetry,
  }) {
    if (!SessionManager().isOnline) {
      return StateMessage.error(title: 'Sin conexión con el servidor', onAction: onRetry);
    }
    return StateMessage.empty(title: title, message: message, icon: icon);
  }

  Widget _categoriesSection() {
    return FormSection(
      title: 'Categorías',
      children: [
        TextField(
          controller: _categoryNameController,
          enabled: !_savingCategory,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Nombre de la categoría',
            hintText: 'Medición',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _categoryDescriptionController,
          enabled: !_savingCategory,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _createCategory(),
          decoration: const InputDecoration(
            labelText: 'Descripción (opcional)',
            hintText: 'Instrumentos para medir magnitudes eléctricas',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: _AddButton(
            label: 'Agregar categoría',
            saving: _savingCategory,
            onPressed: _createCategory,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _ListHeader(count: _categories.length, singular: 'categoría', plural: 'categorías',
            loading: _loadingCategories),
        if (_loadingCategories)
          const _ListLoading()
        else if (_categories.isEmpty)
          _emptyOrOffline(
            title: 'Aún no hay categorías',
            message: 'Agregue la primera con el campo de arriba.',
            icon: Icons.category_outlined,
            onRetry: _loadCategories,
          )
        else
          for (final category in _categories)
            _ListRow(
              title: category.nombre,
              subtitle: category.description,
              deleteTooltip: 'Eliminar la categoría "${category.nombre}"',
              deleting: _deletingCategories.contains(category.id),
              onDelete: () => _deleteCategory(category),
            ),
      ],
    );
  }

  Widget _brandsSection() {
    return FormSection(
      title: 'Marcas',
      children: [
        TextField(
          controller: _brandNameController,
          enabled: !_savingBrand,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _createBrand(),
          decoration: const InputDecoration(
            labelText: 'Nombre de la marca',
            hintText: 'Tektronix',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: _AddButton(
            label: 'Agregar marca',
            saving: _savingBrand,
            onPressed: _createBrand,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _ListHeader(count: _brands.length, singular: 'marca', plural: 'marcas',
            loading: _loadingBrands),
        if (_loadingBrands)
          const _ListLoading()
        else if (_brands.isEmpty)
          _emptyOrOffline(
            title: 'Aún no hay marcas',
            message: 'Agregue la primera con el campo de arriba.',
            icon: Icons.sell_outlined,
            onRetry: _loadBrands,
          )
        else
          for (final brand in _brands)
            _ListRow(
              title: brand.marca,
              deleteTooltip: 'Eliminar la marca "${brand.marca}"',
              deleting: _deletingBrands.contains(brand.id),
              onDelete: () => _deleteBrand(brand),
            ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final bool saving;
  final VoidCallback onPressed;

  const _AddButton({required this.label, required this.saving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: saving ? null : onPressed,
      style: FilledButton.styleFrom(minimumSize: const Size(160, 44)),
      child: saving
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text('Agregando'),
            ])
          : Text(label),
    );
  }
}

/// Cantidad de elementos, encima de la lista, con la línea que abre la
/// primera fila.
class _ListHeader extends StatelessWidget {
  final int count;
  final String singular;
  final String plural;
  final bool loading;

  const _ListHeader({
    required this.count,
    required this.singular,
    required this.plural,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Text(
        loading ? 'Cargando' : '$count ${count == 1 ? singular : plural}',
        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }
}

class _ListLoading extends StatelessWidget {
  const _ListLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: LoadingState(),
    );
  }
}

/// Fila de la lista: nombre, descripción opcional y la acción de eliminar.
class _ListRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String deleteTooltip;
  final bool deleting;
  final VoidCallback onDelete;

  const _ListRow({
    required this.title,
    this.subtitle,
    required this.deleteTooltip,
    required this.deleting,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                if (hasSubtitle) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Tooltip(
            message: deleteTooltip,
            child: TextButton(
              onPressed: deleting ? null : onDelete,
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(deleting ? 'Eliminando' : 'Eliminar'),
            ),
          ),
        ],
      ),
    );
  }
}
