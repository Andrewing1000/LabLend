import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/widgets/card.dart';
import '../models/User.dart';
import '../models/item.dart';

class SearchUserPage extends BrowsablePage {
  BrandFilter brandFilter = BrandFilter(items: []);
  CategoryFilter categoryFilter = CategoryFilter(items: []);

  SearchUserPage({super.key}) {
    //filters.add(brandFilter);
    //filters.add(categoryFilter);
  }

  Future<List<User>> _fetchItems(String? pattern) async {
    return await SessionManager.userManager.getUserList(
      email: pattern,
      //categoryIds: categoryFilter.items.map((cat) => cat.id).toList(),
      //brandId: brandFilter.items.isNotEmpty ? brandFilter.items.first.id : null,
    );
  }

  @override
  Widget build(BuildContext context, SearchField searchField, FilterList filters, Widget? child) {
    String? pattern;
    if (searchField.value.isNotEmpty) {
      pattern = searchField.value;
    }

    return FutureBuilder<List<User>>(
      future: _fetchItems(pattern),
      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white,));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No se encontraron items',
            style: TextStyle(color: Colors.white),));
        } else {
          List<User> items = snapshot.data!;
          return CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(10.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200.0, // Maximum width of each item
                    mainAxisSpacing: 10.0, // Spacing between rows
                    crossAxisSpacing: 10.0, // Spacing between columns
                    childAspectRatio: .5, // Optional: You can adjust this if needed
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return CustomCard(
                        title: items[index].email,
                        subtitle: items[index].name ?? "",
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
  Future<PageBase> onDispose() async {
    return this;
  }
}

class BrandFilter extends Filter<Brand> {
  BrandFilter({required super.items}) : super(attributeName: "Marca", multiple: false);

  @override
  String getRepresentation(Brand item) {
    return item.marca;
  }

  @override
  Future<List<Brand>> retrieveItems() async {
    return await SessionManager.inventory.getBrands();
  }
}

class CategoryFilter extends Filter<Category> {
  CategoryFilter({required super.items}) : super(attributeName: "Categoría", multiple: true);

  @override
  String getRepresentation(Category item) {
    return item.nombre;
  }

  @override
  Future<List<Category>> retrieveItems() async {
    return await SessionManager.inventory.getCategories();
  }
}
