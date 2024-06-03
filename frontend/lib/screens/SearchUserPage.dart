import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/widgets/card.dart';
import '../models/User.dart';
import '../models/item.dart';

class SearchUserPage extends BrowsablePage {

  ActiveFilter activeFilter = ActiveFilter();
  RoleFilter roleFilter = RoleFilter();

  SearchUserPage({super.key}) {
    filterSet.add(activeFilter);
    filterSet.add(roleFilter);
  }

  Future<List<User>> _fetchItems(String? pattern) async {

    bool? isActive;
    if(activeFilter.getSelected().isNotEmpty){
      isActive = activeFilter.getSelected().first == "Activo";
    }

    bool? isAdmin;
    if(roleFilter.getSelected().isNotEmpty){
      isAdmin = roleFilter.getSelected().first == Role.adminRole;
    }

    return await SessionManager.userManager.getUserList(
      email: pattern,
      isActive: isActive,
      isAdmin: isAdmin,
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
  void onDispose() async {
    return;
  }

  @override
  void onSet() {
    return;
  }
}

class ActiveFilter extends SingleFilter<String> {
  ActiveFilter() : super(attributeName: "Estado");

  @override
  String getRepresentation(String item) {
    return item;
  }

  @override
  Future<List<String>> retrieveItems() async {
    return ["Activo", "Inactivo"];
  }
}

class RoleFilter extends Filter<Role> {
  RoleFilter() : super(attributeName: "Rol", multiple: true);

  @override
  String getRepresentation(Role item) {
    return item.name;
  }

  @override
  Future<List<Role>> retrieveItems() async {
    return [Role.adminRole, Role.assistantRole];
  }
}
