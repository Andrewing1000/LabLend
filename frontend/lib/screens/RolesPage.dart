import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/state_message.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Permissions.dart';
import 'package:frontend/models/Role.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/screens/role_edit_screen.dart';
import 'package:frontend/widgets/access_matrix.dart';

/// Gestión de roles (D15): lista los roles con su área, sus permisos y
/// cuántas cuentas los tienen, o los muestra como matriz de accesos (D19).
/// El buscador filtra por nombre de rol.
class RolesPage extends BrowsablePage {
  /// Vista de matriz en lugar de lista.
  final ValueNotifier<bool> showMatrix = ValueNotifier(false);

  RolesPage({super.key});

  Future<List<Role>> _fetchRoles(String pattern) async {
    final roles = await SessionManager.roleService.getRoles();
    final query = pattern.trim().toLowerCase();
    if (query.isEmpty) return roles;
    return roles
        .where((role) => role.name.toLowerCase().contains(query))
        .toList();
  }

  Future<(List<Role>, List<PermissionInfo>)> _fetchMatrix(
      String pattern) async {
    final roles = await _fetchRoles(pattern);
    final permissions = await SessionManager.roleService.getPermissions();
    return (roles, permissions);
  }

  @override
  Widget build(BuildContext context, SearchField searchField,
      FilterList filters, Widget? child) {
    final canManage =
        SessionManager().session.user.can(AppPermission.gestionarRoles);

    return ValueListenableBuilder<bool>(
      valueListenable: showMatrix,
      builder: (context, matrix, _) => Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                          value: false,
                          icon: Icon(Icons.list),
                          label: Text('Lista')),
                      ButtonSegment(
                          value: true,
                          icon: Icon(Icons.grid_on),
                          label: Text('Matriz de accesos')),
                    ],
                    selected: {matrix},
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      selectedForegroundColor: AppColors.onPrimary,
                      selectedBackgroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.border),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSelectionChanged: (value) =>
                        showMatrix.value = value.first,
                  ),
                ),
              ),
              Expanded(
                child: matrix
                    ? _matrixView(searchField.value)
                    : _listView(searchField.value),
              ),
            ],
          ),
          if (canManage && !matrix)
            Positioned(
              right: AppSpacing.xl,
              bottom: AppSpacing.xl,
              child: FloatingActionButton.extended(
                onPressed: () => manager?.setPage(RoleEditScreen()),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: const StadiumBorder(),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo rol'),
              ),
            ),
        ],
      ),
    );
  }

  static const _loading = LoadingState();

  Widget get _empty => StateMessage.emptyOrOffline(
        title: 'No se encontraron roles',
        icon: Icons.badge_outlined,
        onRetry: () => searchField.value = searchField.value,
      );

  // Antes un error se mostraba como "sin roles"; ahora se distingue.
  Widget get _error => StateMessage.error(onAction: () => searchField.value = searchField.value);

  Widget _listView(String pattern) {
    return FutureBuilder<List<Role>>(
      future: _fetchRoles(pattern),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading;
        }
        if (snapshot.hasError) return _error;
        final roles = snapshot.data ?? [];
        if (roles.isEmpty) return _empty;
        final compact = AppBreakpoints.isCompact(context);
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, 0),
              sliver: SliverToBoxAdapter(child: _RolesSummary(roles: roles)),
            ),
            if (!compact)
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xs),
                sliver: SliverToBoxAdapter(child: _RolesHeader()),
              ),
            SliverPadding(
              // Abajo deja lugar al botón "Nuevo rol".
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, 110),
              sliver: SliverList.builder(
                itemCount: roles.length,
                itemBuilder: (context, index) => _RoleCard(
                  role: roles[index],
                  onTap: () =>
                      manager?.setPage(RoleEditScreen(role: roles[index])),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _matrixView(String pattern) {
    return FutureBuilder<(List<Role>, List<PermissionInfo>)>(
      future: _fetchMatrix(pattern),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading;
        }
        if (snapshot.hasError) return _error;
        final (roles, permissions) = snapshot.data ?? (<Role>[], <PermissionInfo>[]);
        if (roles.isEmpty) return _empty;
        return AccessMatrix(roles: roles, permissions: permissions);
      },
    );
  }

  @override
  void onDispose() {}

  @override
  void onSet() {}
}

/// Total de roles y cuántos tiene cada área.
class _RolesSummary extends StatelessWidget {
  final List<Role> roles;

  const _RolesSummary({required this.roles});

  @override
  Widget build(BuildContext context) {
    int count(String? area) => roles.where((r) => r.area == area).length;
    final parts = [
      for (final area in [securityArea, labArea])
        if (count(area) > 0) '${count(area)} de ${areaNames[area]!.toLowerCase()}',
      if (count(null) > 0) '${count(null)} sin permisos',
    ];

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: '${roles.length}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: roles.length == 1 ? '  rol' : '  roles',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          ]),
          style: TextStyle(color: AppColors.textPrimary),
        ),
        if (parts.isNotEmpty)
          Text(parts.join('  ·  '),
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}

/// Anchos de las columnas, compartidos por el encabezado y las filas.
const int _roleFlex = 5;
const double _areaWidth = 150;
const double _countWidth = 96;

/// Títulos de las columnas, alineados con [_RoleCard].
class _RolesHeader extends StatelessWidget {
  const _RolesHeader();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 12,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w700,
      color: AppColors.textMuted,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(flex: _roleFlex, child: Text('ROL', style: style)),
          SizedBox(width: _areaWidth, child: Text('ÁREA', style: style)),
          SizedBox(
              width: _countWidth,
              child: Text('PERMISOS', style: style, textAlign: TextAlign.right)),
          SizedBox(
              width: _countWidth,
              child: Text('USUARIOS', style: style, textAlign: TextAlign.right)),
          const SizedBox(width: 18 + AppSpacing.md),
        ],
      ),
    );
  }
}

/// Fila de la lista de roles: nombre y descripción, área, cantidad de
/// permisos y de usuarios. En pantallas angostas los datos bajan a otra
/// línea.
class _RoleCard extends StatefulWidget {
  final Role role;
  final VoidCallback onTap;

  const _RoleCard({required this.role, required this.onTap});

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool hovered = false;

  static String _readable(String name) =>
      name.replaceAllMapped(RegExp(r'(?<=[a-záéíóúñ])(?=[A-ZÁÉÍÓÚÑ])'), (_) => ' ');

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    final compact = AppBreakpoints.isCompact(context);
    final area = areaNames[role.area] ?? 'Sin permisos';
    final permissions = role.permissions.length;
    final users = role.userCount;

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                _readable(role.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (role.protected) ...[
              const SizedBox(width: AppSpacing.sm),
              Tooltip(
                message: 'Rol protegido: no se modifica ni se elimina',
                child: Icon(Icons.lock_outline, size: 15, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
        if (role.description.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            role.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ],
    );

    final secondary = TextStyle(
      fontSize: 13,
      color: role.area == null ? AppColors.textMuted : AppColors.textSecondary,
    );
    final number = TextStyle(
      fontSize: 14,
      color: AppColors.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Semantics(
      button: true,
      label: '${role.name}, $area, $permissions permisos, $users usuarios'
          '${role.protected ? ', protegido' : ''}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: hovered ? AppColors.surfaceHigh : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      identity,
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '$area  ·  ${permissions == 1 ? '1 permiso' : '$permissions permisos'}'
                        '  ·  ${users == 1 ? '1 usuario' : '$users usuarios'}',
                        style: secondary,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(flex: _roleFlex, child: identity),
                      SizedBox(width: _areaWidth, child: Text(area, style: secondary)),
                      SizedBox(
                        width: _countWidth,
                        child: Text('$permissions', textAlign: TextAlign.right, style: number),
                      ),
                      SizedBox(
                        width: _countWidth,
                        child: Text('$users', textAlign: TextAlign.right, style: number),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: hovered ? AppColors.textSecondary : AppColors.border,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
