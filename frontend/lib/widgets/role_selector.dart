import 'package:frontend/themes/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Role.dart';

/// Selección de los roles de una cuenta (D15). Aplica en pantalla las
/// mismas reglas que el servidor (D18): no se combinan roles de seguridad
/// y de laboratorio, y los de seguridad solo se eligen al crear la cuenta.
class RoleSelector extends StatelessWidget {
  final List<Role> roles;
  final Set<String> selected;
  /// Cuenta existente: sus roles de seguridad no se dan ni se quitan.
  final bool existingAccount;
  final bool enabled;
  final ValueChanged<Set<String>> onChanged;

  const RoleSelector({
    super.key,
    required this.roles,
    required this.selected,
    required this.existingAccount,
    required this.enabled,
    required this.onChanged,
  });

  String? get _selectedArea {
    for (final role in roles) {
      if (selected.contains(role.name) && role.area != null) {
        return role.area;
      }
    }
    return null;
  }

  bool _selectable(Role role) {
    if (!enabled) return false;
    if (existingAccount && role.isSecurity) return false;
    final area = _selectedArea;
    return area == null || role.area == null || role.area == area
        || selected.contains(role.name);
  }

  /// Por qué no se puede elegir un rol, para mostrarlo en la tarjeta.
  String? _blockedReason(Role role) {
    if (!enabled || _selectable(role)) return null;
    if (existingAccount && role.isSecurity) {
      return 'Solo se asigna al crear la cuenta';
    }
    return 'No se combina con roles de ${areaNames[_selectedArea] ?? 'otra área'}';
  }

  static String _readable(String name) =>
      name.replaceAllMapped(RegExp(r'(?<=[a-záéíóúñ])(?=[A-ZÁÉÍÓÚÑ])'), (_) => ' ');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 560 ? 2 : 1;
      final width = (constraints.maxWidth - AppSpacing.md * (columns - 1)) / columns;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final role in roles)
                SizedBox(
                  width: width,
                  child: _RoleOption(
                    name: _readable(role.name),
                    description: role.description,
                    area: role.area,
                    selected: selected.contains(role.name),
                    selectable: _selectable(role),
                    blockedReason: _blockedReason(role),
                    onTap: () {
                      final next = Set.of(selected);
                      selected.contains(role.name) ? next.remove(role.name) : next.add(role.name);
                      onChanged(next);
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  existingAccount
                      ? 'Una cuenta no combina roles de seguridad y de laboratorio. '
                          'Los roles de seguridad solo se asignan al crear la cuenta.'
                      : 'Una cuenta no combina roles de seguridad y de laboratorio '
                          '(segregación de funciones).',
                  style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _RoleOption extends StatelessWidget {
  final String name;
  final String description;
  /// Área del rol, o null si todavía no tiene permisos.
  final String? area;
  final bool selected;
  final bool selectable;
  final String? blockedReason;
  final VoidCallback onTap;

  const _RoleOption({
    required this.name,
    required this.description,
    required this.area,
    required this.selected,
    required this.selectable,
    required this.blockedReason,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final areaLabel = areaNames[area] ?? 'Sin permisos';

    return Semantics(
      checked: selected,
      enabled: selectable,
      label: name,
      child: Opacity(
        opacity: selectable ? 1 : 0.45,
        child: InkWell(
          onTap: selectable ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: selected ? AppColors.textSecondary : AppColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    selected ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 18,
                    color: selected ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        blockedReason ?? (description.isNotEmpty ? '$areaLabel · $description' : areaLabel),
                        style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
