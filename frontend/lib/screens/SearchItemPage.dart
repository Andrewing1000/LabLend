import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/widgets/card.dart';
import '../models/item.dart';
import '../services/SelectedItemContext.dart';

class SearchItemPage extends BrowsablePage {
  BrandFilter brandFilter = BrandFilter();
  CategoryFilter categoryFilter = CategoryFilter();
  SelectedItemContext selectedItem;
  SearchItemPage({super.key, required this.selectedItem}) {
    filterSet.add(brandFilter);
    filterSet.add(categoryFilter);
  }

  Future<List<Item>> _fetchItems(String? pattern) async {
    return await SessionManager.inventory.getItems(
      namePattern: pattern,
      categoryIds: categoryFilter.getSelected().map((cat) => cat.id).toList(),
      brandId: brandFilter.getSelected().isNotEmpty ? brandFilter.getSelected().first.id : null,
    );
  }

  @override
  Widget build(BuildContext context, SearchField searchField,
      FilterList filters, Widget? child) {
    String? pattern;
    if (searchField.value.isNotEmpty) {
      pattern = searchField.value;
    }

    return FutureBuilder<List<Item>>(
      future: _fetchItems(pattern),
      builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white,));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontraron items',
          style: TextStyle(color: Colors.white),));
        } else {
          List<Item> items = snapshot.data!;
          return CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(10.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200.0, // Maximum width of each item
                    mainAxisSpacing: 10.0, // Spacing between rows
                    crossAxisSpacing: 10.0, // Spacing between columns
                    childAspectRatio:
                        .5, // Optional: You can adjust this if needed
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return CustomCard(
                        title: items[index].nombre,
                        subtitle: items[index].description ?? "",
                        onTap: (){
                          selectedItem.setItem(items[index]);
                        },
                      );
                    },
                    childCount: items.length, // Number of items in the grid
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  void onDispose() async {
    return;
  }

  @override
  void onSet() {
    return;
  }
}

class BrandFilter extends SingleFilter<Brand>{
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
