import 'package:frontend/models/Permissions.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/screens/create_user.dart';
import 'package:frontend/screens/user_edit_screen.dart';
import 'package:frontend/widgets/UserCard.dart';
import '../models/User.dart';

class SearchUserPage extends BrowsablePage {
  ActiveFilter activeFilter = ActiveFilter();
  RoleFilter roleFilter = RoleFilter();

  SearchUserPage({super.key}) {
    filterSet.add(activeFilter);
    filterSet.add(roleFilter);
  }

  Future<List<User>> _fetchItems(String? pattern) async {
    bool? isActive;
    if (activeFilter.getSelected().isNotEmpty) {
      isActive = activeFilter.getSelected().first == "Activo";
    }

    String? role;
    if (roleFilter.getSelected().isNotEmpty) {
      role = roleFilter.getSelected().first;
    }

    return await SessionManager.userManager.getUserList(
      email: pattern,
      isActive: isActive,
      role: role,
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
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron items',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          List<User> items = snapshot.data!;
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: Colors.white,
                          width: 1,
                        ),
                      )
                    ),
                    padding: const EdgeInsets.fromLTRB(40.0, 20, 40, 20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text(
                            'Usuario',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w100,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text(
                            'Rol',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w100,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(width: 16),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Text(
                            'Estado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w100,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.all(10.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                return UserCard(
                                  user: items[index],
                                  onTap: () {
                                    manager?.setPage(EditUserScreen(
                                      user: items[index],
                                    ));
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
                ],
              ),
              if (SessionManager().session.user.can(AppPermission.crearUsuarios))
                Align(
                  alignment: const Alignment(1, 1),
                  child: Container(
                    padding: const EdgeInsets.all(50),
                    child: FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(200),
                      ),
                      onPressed: () {
                        if (manager != null) {
                          manager?.setPage(CreateUserScreen());
                        }
                      },
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
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

/// Filtra por nombre de rol, con los roles que existen en el servidor (D15).
class RoleFilter extends SingleFilter<String> {
  RoleFilter() : super(attributeName: "Rol");

  @override
  String getRepresentation(String item) {
    return item;
  }

  @override
  Future<List<String>> retrieveItems() async {
    final roles = await SessionManager.roleService.getRoles();
    return [for (final role in roles) role.name];
  }
}
