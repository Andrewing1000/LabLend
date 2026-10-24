import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/models/User.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/services/PageManager.dart';
import 'package:frontend/themes/AppTheme.dart';

/// Una sección de la aplicación a la que se llega desde el menú.
class AppNavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final PageBase page;

  /// Permiso que hace falta para ver la opción (D17). Sin permiso, la opción
  /// no aparece en el menú.
  final String? permission;

  const AppNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
    this.permission,
  });

  bool isVisibleFor(User user) => permission == null || user.can(permission!);
}

/// Opciones del menú que el usuario actual puede ver.
List<AppNavItem> visibleNavItems(List<AppNavItem> items) {
  final user = SessionManager().session.user;
  return items.where((item) => item.isVisibleFor(user)).toList();
}

/// Iniciales para el botón de la cuenta.
String userInitials(User user) {
  final parts = [user.nombres, user.apellidoPaterno]
      .where((p) => p.trim().isNotEmpty)
      .map((p) => p.trim()[0].toUpperCase());
  final initials = parts.join();
  return initials.isEmpty ? user.username.substring(0, 1).toUpperCase() : initials;
}

/// Menú inferior en forma de píldora, para pantallas angostas.
class BottomNavPill extends StatelessWidget {
  final List<AppNavItem> items;
  final PageManager manager;
  final int cartCount;
  final bool showCart;
  final VoidCallback onCart;
  final VoidCallback onMore;

  const BottomNavPill({
    super.key,
    required this.items,
    required this.manager,
    required this.cartCount,
    required this.showCart,
    required this.onCart,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    // Inicio y Equipos van fijos; el resto queda en "Más".
    final primary = items.take(2).toList();

    return Material(
      color: AppColors.textPrimary,
      elevation: 8,
      shadowColor: Colors.black,
      shape: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in primary)
              _PillButton(
                icon: manager.currentPage == item.page ? item.selectedIcon : item.icon,
                label: item.label,
                selected: manager.currentPage == item.page,
                onTap: () => manager.setPage(item.page),
              ),
            if (showCart)
              _PillButton(
                icon: Icons.shopping_cart_outlined,
                label: 'Mi préstamo ($cartCount)',
                badge: cartCount,
                onTap: onCart,
              ),
            _PillButton(
              icon: Icons.menu,
              label: 'Más opciones',
              onTap: onMore,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 28,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: selected ? AppColors.background : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 24,
                    color: selected ? AppColors.textPrimary : AppColors.background),
                if (badge > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _Badge(count: badge),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      child: Text('$count',
          style: const TextStyle(
              color: AppColors.onPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

/// Hoja inferior con todas las secciones y las acciones de la cuenta.
Future<void> showMoreSheet({
  required BuildContext context,
  required List<AppNavItem> items,
  required PageManager manager,
  required VoidCallback onLogin,
  required VoidCallback onLogout,
  VoidCallback? onChangePassword,
  VoidCallback? onProfile,
}) {
  final user = SessionManager().session.user;
  final isVisitor = user is VisitorUser;

  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceHigh,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (sheetContext) {
      void go(VoidCallback action) {
        Navigator.of(sheetContext).pop();
        action();
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isVisitor)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryMuted,
                    child: Text(userInitials(user),
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                  ),
                  title: Text(user.name, style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text(user.roles.join(', '),
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              for (final item in items)
                ListTile(
                  leading: Icon(
                      manager.currentPage == item.page ? item.selectedIcon : item.icon,
                      color: manager.currentPage == item.page
                          ? AppColors.primary
                          : AppColors.textPrimary),
                  title: Text(item.label),
                  selected: manager.currentPage == item.page,
                  selectedColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                  onTap: () => go(() => manager.setPage(item.page)),
                ),
              const Divider(height: AppSpacing.xl),
              if (!isVisitor && onProfile != null)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Mi perfil'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                  onTap: () => go(onProfile),
                ),
              if (!isVisitor && onChangePassword != null)
                ListTile(
                  leading: const Icon(Icons.key_outlined),
                  title: const Text('Cambiar contraseña'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                  onTap: () => go(onChangePassword),
                ),
              ListTile(
                leading: Icon(isVisitor ? Icons.login : Icons.logout),
                title: Text(isVisitor ? 'Iniciar sesión' : 'Cerrar sesión'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                onTap: () => go(isVisitor ? onLogin : onLogout),
              ),
            ],
          ),
        ),
      );
    },
  );
}
