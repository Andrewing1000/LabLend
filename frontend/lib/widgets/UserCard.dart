import 'package:frontend/themes/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/User.dart';
import 'app_nav.dart';

/// Estado de una cuenta para mostrar, del más importante al menos: una
/// cuenta inactiva o bloqueada no puede entrar aunque cumpla lo demás.
enum AccountStatus {
  inactive('Inactiva', Icons.block, AppColors.textMuted),
  locked('Bloqueada', Icons.lock_outline, AppColors.error),
  pending('Sin activar', Icons.mark_email_unread_outlined, AppColors.primary),
  expired('Contraseña vencida', Icons.lock_clock_outlined, AppColors.warning),
  active('Activa', Icons.check_circle_outline, AppColors.success);

  final String label;
  final IconData icon;
  final Color color;
  const AccountStatus(this.label, this.icon, this.color);

  static AccountStatus of(User user) {
    if (!user.isActive) return inactive;
    if (user.isLocked) return locked;
    if (user.activationPending) return pending;
    if (user.passwordExpired) return expired;
    return active;
  }
}

/// Píldora de color con el estado de la cuenta.
class AccountStatusBadge extends StatelessWidget {
  final AccountStatus status;
  const AccountStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 1),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: status.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            status.label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: status.color),
          ),
        ],
      ),
    );
  }
}

/// Fila de la lista de usuarios: avatar, nombre, código y correo, roles y
/// estado. En pantallas angostas los roles y el estado bajan a otra línea.
class UserCard extends StatefulWidget {
  final User user;
  final VoidCallback onTap;

  const UserCard({super.key, required this.user, required this.onTap});

  /// Anchos de las columnas, compartidos con el encabezado de la lista.
  static const int userFlex = 5;
  static const int rolesFlex = 4;
  static const double statusWidth = 190;

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.user,
      child: Consumer<User>(
        builder: (context, user, child) {
          final status = AccountStatus.of(user);
          final compact = AppBreakpoints.isCompact(context);
          final avatarColor = user.securityAccount ? AppColors.warning : AppColors.primary;

          final identity = Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: avatarColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  userInitials(user),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: avatarColor,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isEmpty ? user.username : user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: user.username,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const TextSpan(text: '  ·  '),
                        TextSpan(text: user.email),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          );

          final roles = user.roles.isEmpty
              ? const Text('Sin roles',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic))
              : Wrap(
                  spacing: AppSpacing.xs + 2,
                  runSpacing: AppSpacing.xs + 2,
                  children: [for (final role in user.roles) _RoleChip(name: role)],
                );

          return Semantics(
            button: true,
            label: '${user.name}, ${user.username}, ${status.label}',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg + 4, vertical: AppSpacing.md + 2),
                  decoration: BoxDecoration(
                    color: isHovered ? AppColors.surfaceHighest : AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(AppRadius.md + 2),
                    border: Border.all(
                      color: isHovered ? AppColors.primary.withOpacity(0.4) : Colors.transparent,
                    ),
                  ),
                  child: compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            identity,
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(child: roles),
                                const SizedBox(width: AppSpacing.sm),
                                AccountStatusBadge(status: status),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(flex: UserCard.userFlex, child: identity),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(flex: UserCard.rolesFlex, child: roles),
                            SizedBox(
                              width: UserCard.statusWidth,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AccountStatusBadge(status: status),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: isHovered ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String name;
  const _RoleChip({required this.name});

  /// "AdministradorSeguridad" → "Administrador Seguridad".
  static String _readable(String name) =>
      name.replaceAllMapped(RegExp(r'(?<=[a-záéíóúñ])(?=[A-ZÁÉÍÓÚÑ])'), (_) => ' ');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        _readable(name),
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}
