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

/// Estado de la cuenta: un punto de color y el texto, sin fondo ni borde.
class AccountStatusBadge extends StatelessWidget {
  final AccountStatus status;
  const AccountStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          status.label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
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

          final identity = Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceHighest,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  userInitials(user),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textSecondary,
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
                        fontWeight: FontWeight.w600,
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

          final roles = Text(
            user.roles.isEmpty ? 'Sin roles' : user.roles.map(readableRole).join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: user.roles.isEmpty ? AppColors.textMuted : AppColors.textSecondary,
            ),
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: isHovered ? AppColors.surfaceHigh : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: const Border(bottom: BorderSide(color: AppColors.border)),
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
                              size: 18,
                              color: isHovered ? AppColors.textSecondary : AppColors.border,
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

/// "AdministradorSeguridad" → "Administrador Seguridad".
String readableRole(String name) =>
    name.replaceAllMapped(RegExp(r'(?<=[a-záéíóúñ])(?=[A-ZÁÉÍÓÚÑ])'), (_) => ' ');
