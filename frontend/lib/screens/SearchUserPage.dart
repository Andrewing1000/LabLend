import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/state_message.dart';
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

  // El servidor busca por parecido del correo (user/filters.py).
  SearchUserPage({super.key}) : super(searchHint: 'Buscar por correo') {
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
          return const LoadingState();
        } else if (snapshot.hasError) {
          return StateMessage.error(onAction: () => searchField.value = searchField.value);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return StateMessage.emptyOrOffline(
            title: 'No se encontraron usuarios',
            icon: Icons.person_search_outlined,
            onRetry: () => searchField.value = searchField.value,
          );
        } else {
          final items = snapshot.data!;
          final canCreate =
              SessionManager().session.user.can(AppPermission.crearUsuarios);
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
                    sliver: SliverToBoxAdapter(child: _UsersSummary(users: items)),
                  ),
                  if (!AppBreakpoints.isCompact(context))
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xs),
                      sliver: SliverToBoxAdapter(child: _UsersHeader()),
                    ),
                  SliverPadding(
                    // Abajo deja lugar al botón "Nuevo usuario".
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, 110),
                    sliver: SliverList.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) => UserCard(
                        user: items[index],
                        onTap: () => manager?.setPage(EditUserScreen(user: items[index])),
                      ),
                    ),
                  ),
                ],
              ),
              if (canCreate)
                Positioned(
                  right: AppSpacing.xl,
                  bottom: AppSpacing.xl,
                  child: FloatingActionButton.extended(
                    onPressed: () => manager?.setPage(CreateUserScreen()),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: const StadiumBorder(),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Nuevo usuario'),
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

/// Total de cuentas y cuántas necesitan atención (bloqueadas, sin activar o
/// con la contraseña vencida).
class _UsersSummary extends StatelessWidget {
  final List<User> users;
  const _UsersSummary({required this.users});

  @override
  Widget build(BuildContext context) {
    int count(AccountStatus status) =>
        users.where((u) => AccountStatus.of(u) == status).length;

    final chips = [
      for (final status in AccountStatus.values)
        if (count(status) > 0) (status, count(status)),
    ];

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: '${users.length}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: users.length == 1 ? '  cuenta' : '  cuentas',
              style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          ]),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        for (final (status, n) in chips)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Text('$n ${status.label.toLowerCase()}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
      ],
    );
  }
}

/// Títulos de las columnas, alineados con [UserCard].
class _UsersHeader extends StatelessWidget {
  const _UsersHeader();

  static const _style = TextStyle(
    fontSize: 12,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
  );

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg + 5),
      child: Row(
        children: [
          Expanded(flex: UserCard.userFlex, child: Text('USUARIO', style: _style)),
          SizedBox(width: AppSpacing.lg),
          Expanded(flex: UserCard.rolesFlex, child: Text('ROLES', style: _style)),
          SizedBox(width: UserCard.statusWidth, child: Text('ESTADO', style: _style)),
          SizedBox(width: 24),
        ],
      ),
    );
  }
}
