import 'dart:math';

import 'package:frontend/themes/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Role.dart';

/// Matriz de accesos (D19): qué permiso tiene cada rol, con los datos del
/// servidor. Incluye los roles creados desde la aplicación, así que siempre
/// coincide con lo que el servidor permite.
///
/// Filas: funciones (permisos) agrupadas por área. Columnas: roles. Cada
/// celda marca si el rol tiene ese permiso.
class AccessMatrix extends StatelessWidget {
  final List<Role> roles;
  final List<PermissionInfo> permissions;

  const AccessMatrix({super.key, required this.roles, required this.permissions});

  static const double _functionMinWidth = 300;
  static const double _roleWidth = 136;
  static const double _outerPadding = AppSpacing.xl;

  static IconData _areaIcon(String area) =>
      area == securityArea ? Icons.shield_outlined : Icons.biotech_outlined;

  /// "AdministradorLaboratorio" → "Administrador Laboratorio", para que el
  /// nombre del rol pueda partirse en dos líneas.
  static String _readableName(String name) =>
      name.replaceAllMapped(RegExp(r'(?<=[a-záéíóúñ])(?=[A-ZÁÉÍÓÚÑ])'), (_) => ' ');

  @override
  Widget build(BuildContext context) {
    final areas = [securityArea, labArea]
        .where((area) => permissions.any((p) => p.area == area))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth - _outerPadding * 2;
        final tableWidth =
            max(available, _functionMinWidth + _roleWidth * roles.length);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(_outerPadding, 0, _outerPadding, _outerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En pantallas angostas la tabla se desplaza de lado.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: tableWidth,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeaderRow(roles: roles, permissions: permissions),
                      for (final area in areas) ...[
                        _AreaRow(
                          area: area,
                          icon: _areaIcon(area),
                          roles: roles,
                          permissions: permissions.where((p) => p.area == area).toList(),
                        ),
                        for (final permission in permissions.where((p) => p.area == area))
                          _PermissionRow(permission: permission, roles: roles),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _Legend(),
            ],
          ),
        );
      },
    );
  }
}

/// Encabezado: "Función" y una columna por rol con su nombre, área y cuántos
/// permisos tiene.
class _HeaderRow extends StatelessWidget {
  final List<Role> roles;
  final List<PermissionInfo> permissions;

  const _HeaderRow({required this.roles, required this.permissions});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'FUNCIÓN',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            for (final role in roles)
              SizedBox(
                width: AccessMatrix._roleWidth,
                child: Tooltip(
                  message: role.description.isEmpty ? role.name : role.description,
                  child: _RoleHeader(role: role, total: permissions.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleHeader extends StatelessWidget {
  final Role role;
  final int total;

  const _RoleHeader({required this.role, required this.total});

  @override
  Widget build(BuildContext context) {
    final granted = role.permissions.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            AccessMatrix._readableName(role.name),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            role.protected ? '$granted de $total · protegido' : '$granted de $total',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Fila de título de un área, con cuántos permisos del área tiene cada rol.
class _AreaRow extends StatelessWidget {
  final String area;
  final IconData icon;
  final List<Role> roles;
  final List<PermissionInfo> permissions;

  const _AreaRow({
    required this.area,
    required this.icon,
    required this.roles,
    required this.permissions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  Text(
                    areaNames[area] ?? area,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${permissions.length} funciones',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          for (final role in roles)
            SizedBox(
              width: AccessMatrix._roleWidth,
              child: Center(
                child: Text(
                  '${permissions.where((p) => role.permissions.contains(p.codename)).length}'
                  '/${permissions.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Una función y, en cada columna, si el rol la tiene.
class _PermissionRow extends StatefulWidget {
  final PermissionInfo permission;
  final List<Role> roles;

  const _PermissionRow({required this.permission, required this.roles});

  @override
  State<_PermissionRow> createState() => _PermissionRowState();
}

class _PermissionRowState extends State<_PermissionRow> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final permission = widget.permission;

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: hovered ? AppColors.surfaceHighest.withOpacity(0.6) : Colors.transparent,
          border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permission.name,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs + 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        permission.codename,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (final role in widget.roles)
              SizedBox(
                width: AccessMatrix._roleWidth,
                child: Center(
                  child: _AccessMark(
                    granted: role.permissions.contains(permission.codename),
                    label: '${role.name}: ${permission.name}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AccessMark extends StatelessWidget {
  final bool granted;
  final String label;

  const _AccessMark({required this.granted, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: ${granted ? 'permitido' : 'no permitido'}',
      excludeSemantics: true,
      child: granted
          ? const Icon(Icons.check, size: 18, color: AppColors.textPrimary)
          : Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.border,
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 12, color: AppColors.textSecondary);
    return Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Row(mainAxisSize: MainAxisSize.min, children: [
          _AccessMark(granted: true, label: 'Leyenda'),
          SizedBox(width: AppSpacing.sm),
          Text('Tiene el permiso', style: style),
        ]),
        const Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 18, child: Center(child: _AccessMark(granted: false, label: 'Leyenda'))),
          SizedBox(width: AppSpacing.sm),
          Text('No lo tiene', style: style),
        ]),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: const Text(
            'Sin sesión (visitante): solo consulta el catálogo de equipos. Toda '
            'cuenta, con cualquier rol, ve y edita su perfil y cambia su contraseña.',
            style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
