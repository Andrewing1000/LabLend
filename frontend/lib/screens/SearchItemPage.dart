import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/screens/create_item_screen.dart';
import 'package:frontend/screens/edit_item_screen.dart';
import 'package:frontend/widgets/card.dart';
import '../models/User.dart';
import '../models/Item.dart';
import '../services/SelectedItemContext.dart';

import "package:provider/provider.dart";
class SearchItemPage extends BrowsablePage {
  BrandFilter brandFilter = BrandFilter();
  CategoryFilter categoryFilter = CategoryFilter();
  SelectedItemContext selectedItem;
  SearchItemPage({super.key,
    required this.selectedItem,}) {
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
        List<Item> items = [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white,));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
        if (snapshot.hasData && !snapshot.data!.isEmpty) {
          items = snapshot.data!;
        }
          return MultiProvider(

            providers: [
                  ChangeNotifierProvider.value(value: SessionManager()),
            ],
            child: Consumer<SessionManager>(
              builder: (context, sessionManager, child) {
                return Stack(
                  children: [
                    if(items.isEmpty)
                    const Center(child: Text('No se encontraron items',
                      style: TextStyle(color: Colors.white),)),
                    if(items.isNotEmpty) CustomScrollView(
                      slivers: <Widget>[
                        StatefulBuilder(
                          builder: (context, setState) {
                            return SliverPadding(
                              padding: const EdgeInsets.all(10.0),
                              sliver: SliverGrid(
                                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: CustomCard.width, // Maximum width of each item
                                  mainAxisSpacing: 10.0, // Spacing between rows
                                  crossAxisSpacing: 10.0, // Spacing between columns
                                  childAspectRatio: CustomCard.width/CustomCard.height,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return CustomCard(
                                      item: items[index],
                                      onTap: (){
                                        selectedItem.setItem(items[index]);
                                      },
                                      onEdit: (){
                                        manager?.setPage(EditItemScreen(item: items[index]));
                                      },
                                      onDelete: () async {
                                        var res = await sessionManager.confirmNotification(
                                            message: "El item \"${items[index].nombre}\" será eliminado");
                                        if(!res) return;
                                        SessionManager.inventory.deleteItem(items[index]);
                                        items.removeAt(index);
                                        setState((){});

                                      },
                                    );
                                  },
                                  childCount: items.length, // Number of items in the grid
                                ),
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                    if(sessionManager.session.user.role == Role.adminRole)
                      Align(
                        alignment: const Alignment(1, 1),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          child: FloatingActionButton(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(200),
                            ),
                            //label: Text("Agregar"),
                            onPressed: (){
                                if(manager != null){
                                  manager?.setPage(CreateItemScreen());
                                }
                            },
                            child: const Icon(Icons.add, color: Colors.black,)),
                        ),
                      ),
                  ],
                );
              }
            ),
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
