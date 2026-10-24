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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Roles',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final role in roles)
              FilterChip(
                label: Text(role.name),
                tooltip: role.description.isEmpty ? null : role.description,
                selected: selected.contains(role.name),
                showCheckmark: true,
                checkmarkColor: AppColors.background,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceHigh,
                disabledColor: AppColors.surfaceHigh,
                labelStyle: TextStyle(
                  color: selected.contains(role.name)
                      ? AppColors.background
                      : (_selectable(role) ? AppColors.textPrimary : AppColors.textMuted),
                ),
                onSelected: _selectable(role)
                    ? (value) {
                        final next = Set.of(selected);
                        value ? next.add(role.name) : next.remove(role.name);
                        onChanged(next);
                      }
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          existingAccount
              ? 'Una cuenta no combina roles de seguridad y de laboratorio. '
                  'Los roles de seguridad solo se asignan al crear la cuenta.'
              : 'Una cuenta no combina roles de seguridad y de laboratorio. '
                  'Con un rol de seguridad, el código de usuario empieza '
                  'con adm.',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
