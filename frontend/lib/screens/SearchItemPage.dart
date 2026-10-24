import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/state_message.dart';
import 'package:frontend/models/Permissions.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/screens/create_item_screen.dart';
import 'package:frontend/screens/edit_item_screen.dart';
import 'package:frontend/widgets/card.dart';
import '../models/Inventory.dart';
import '../models/Item.dart';
import '../services/SelectedItemContext.dart';

class SearchItemPage extends BrowsablePage {
  BrandFilter brandFilter = BrandFilter();
  CategoryFilter categoryFilter = CategoryFilter();
  SelectedItemContext selectedItem;
  SearchItemPage({
    super.key,
    required this.selectedItem,
  }) {
    filterSet.add(brandFilter);
    filterSet.add(categoryFilter);
  }

  Future<List<Item>> _fetchItems(String? pattern) async {
    return await SessionManager.inventory.getItems(
      namePattern: pattern,
      categoryIds: categoryFilter.getSelected().map((cat) => cat.id).toList(),
      brandId: brandFilter.getSelected().isNotEmpty
          ? brandFilter.getSelected().first.id
          : null,
    );
  }

  // La lista se guarda mientras no cambien la búsqueda ni los filtros: así no
  // se vuelve a pedir al servidor cada vez que la pantalla se redibuja (por
  // ejemplo, al cambiar de modo noche o día).
  String? _cacheKey;
  Future<List<Item>>? _cache;

  Future<List<Item>> _items(String? pattern) {
    final key = [
      pattern ?? '',
      categoryFilter.getSelected().map((c) => c.id).join(','),
      brandFilter.getSelected().map((b) => b.id).join(','),
      // Después de prestar o devolver se vuelven a pedir las unidades.
      Inventory.stockChanged.value,
    ].join('|');
    if (key != _cacheKey || _cache == null) {
      _cacheKey = key;
      _cache = _fetchItems(pattern);
    }
    return _cache!;
  }

  void _invalidate() {
    _cacheKey = null;
    _cache = null;
  }

  @override
  Widget build(BuildContext context, SearchField searchField,
      FilterList filters, Widget? child) {
    String? pattern;
    if (searchField.value.isNotEmpty) {
      pattern = searchField.value;
    }

    void retry() {
      _invalidate();
      searchField.value = searchField.value;
    }

    return ValueListenableBuilder<int>(
      valueListenable: Inventory.stockChanged,
      builder: (context, _, __) => FutureBuilder<List<Item>>(
        future: _items(pattern),
        builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState();
          }
          if (snapshot.hasError) {
            return StateMessage.error(onAction: retry);
          }
          final items = snapshot.data ?? <Item>[];

          // Escucha la sesión: el botón de nuevo equipo aparece al iniciar
          // sesión con permiso y desaparece al cerrarla.
          return ListenableBuilder(
            listenable: SessionManager(),
            builder: (context, _) {
              final canManage = SessionManager()
                  .session
                  .user
                  .can(AppPermission.gestionarInventario);

              return Stack(
                children: [
                  if (items.isEmpty)
                    StateMessage.emptyOrOffline(
                        title: 'No se encontraron equipos', onRetry: retry)
                  else
                    StatefulBuilder(
                      builder: (context, setState) => CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.xl,
                                AppSpacing.xl, AppSpacing.xl, 110),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: CustomCard.width,
                                mainAxisSpacing: AppSpacing.xl,
                                crossAxisSpacing: AppSpacing.lg + 4,
                                childAspectRatio:
                                    CustomCard.width / CustomCard.height,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = items[index];
                                  return CustomCard(
                                    item: item,
                                    onTap: () => selectedItem.setItem(item),
                                    onEdit: () => manager
                                        ?.setPage(EditItemScreen(item: item)),
                                    onDelete: () async {
                                      final confirmed = await SessionManager()
                                          .confirmNotification(
                                              message:
                                                  'El equipo "${item.nombre}" será eliminado.');
                                      if (!confirmed) return;
                                      // Solo se quita de la lista si el servidor lo eliminó.
                                      final deleted = await SessionManager
                                          .inventory
                                          .deleteItem(item);
                                      if (!deleted) return;
                                      if (selectedItem.item == item)
                                        selectedItem.unsetItem();
                                      setState(() => items.remove(item));
                                    },
                                  );
                                },
                                childCount: items.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (canManage)
                    Positioned(
                      right: AppSpacing.xl,
                      bottom: AppSpacing.xl,
                      child: FloatingActionButton.extended(
                        onPressed: () => manager?.setPage(CreateItemScreen()),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: const StadiumBorder(),
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo equipo'),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  void onDispose() async {
    return;
  }

  /// Al volver a la página (por ejemplo, después de crear o editar un
  /// equipo) la lista se pide de nuevo.
  @override
  void onSet() {
    _invalidate();
  }
}

class BrandFilter extends SingleFilter<Brand> {
  BrandFilter({super.items}) : super(attributeName: "Marca");

  @override
  String getRepresentation(Brand item) {
    return item.marca;
  }

  @override
  Future<List<Brand>> retrieveItems() async {
    return await SessionManager.inventory.getBrands();
  }
}

class CategoryFilter extends MultipleFilter<Category> {
  CategoryFilter({super.items}) : super(attributeName: "Categoría");

  @override
  String getRepresentation(Category item) {
    return item.nombre;
  }

  @override
  Future<List<Category>> retrieveItems() async {
    return await SessionManager.inventory.getCategories();
  }
}
