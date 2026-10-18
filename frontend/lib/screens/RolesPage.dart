import 'package:flutter/material.dart';
import 'package:frontend/models/Permissions.dart';
import 'package:frontend/models/Role.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/screens/role_edit_screen.dart';

/// Gestión de roles (D15): lista los roles con su área, sus permisos y
/// cuántas cuentas los tienen. El buscador filtra por nombre.
class RolesPage extends BrowsablePage {
  RolesPage({super.key});

  Future<List<Role>> _fetchRoles(String pattern) async {
    final roles = await SessionManager.roleService.getRoles();
    final query = pattern.trim().toLowerCase();
    if (query.isEmpty) return roles;
    return roles
        .where((role) => role.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context, SearchField searchField,
      FilterList filters, Widget? child) {
    final canManage =
        SessionManager().session.user.can(AppPermission.gestionarRoles);

    return Stack(
      children: [
        FutureBuilder<List<Role>>(
          future: _fetchRoles(searchField.value),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            final roles = snapshot.data ?? [];
            if (roles.isEmpty) {
              return const Center(
                child: Text('No se encontraron roles',
                    style: TextStyle(color: Colors.white)),
              );
            }
            return Column(
              children: [
                const _RolesHeader(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: roles.length,
                    itemBuilder: (context, index) => _RoleCard(
                      role: roles[index],
                      onTap: () => manager?.setPage(
                          RoleEditScreen(role: roles[index])),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (canManage)
          Align(
            alignment: const Alignment(1, 1),
            child: Container(
              padding: const EdgeInsets.all(50),
              child: FloatingActionButton(
                tooltip: 'Nuevo rol',
                backgroundColor: Theme.of(context).primaryColor,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(200),
                ),
                onPressed: () => manager?.setPage(RoleEditScreen()),
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void onDispose() {}

  @override
  void onSet() {}
}

class _RolesHeader extends StatelessWidget {
  const _RolesHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
        fontSize: 18, fontWeight: FontWeight.w100, color: Colors.white);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
      child: const Row(
        children: [
          Expanded(flex: 4, child: Text('Rol', style: style)),
          Expanded(flex: 2, child: Text('Área', style: style)),
          Expanded(
              flex: 2,
              child: Text('Permisos',
                  style: style, textAlign: TextAlign.center)),
          Expanded(
              flex: 2,
              child: Text('Usuarios',
                  style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final Role role;
  final VoidCallback onTap;

  const _RoleCard({required this.role, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 14, 30, 14),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(role.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        if (role.protected) ...[
                          const SizedBox(width: 8),
                          const Tooltip(
                            message: 'Rol protegido: no se modifica ni se '
                                'elimina',
                            child: Icon(Icons.lock,
                                size: 16, color: Colors.orange),
                          ),
                        ],
                      ],
                    ),
                    if (role.description.isNotEmpty)
                      Text(role.description,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(areaNames[role.area] ?? 'Sin permisos',
                    style: const TextStyle(color: Colors.grey)),
              ),
              Expanded(
                flex: 2,
                child: Text('${role.permissions.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white)),
              ),
              Expanded(
                flex: 2,
                child: Text('${role.userCount}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
