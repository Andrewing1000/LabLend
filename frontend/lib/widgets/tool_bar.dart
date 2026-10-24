import 'package:frontend/models/Permissions.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/User.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/services/Cart.dart';
import 'package:frontend/widgets/DropDownFilter.dart';
import 'package:frontend/widgets/app_nav.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/PageManager.dart';
import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/themes/theme_controller.dart';

import '../models/Session.dart';
import 'DropdownDateFilter.dart';

/// Barra superior: logo, menú (en pantallas anchas), préstamo en curso y
/// cuenta. En las páginas de búsqueda agrega el buscador y los filtros.
class ToolBar extends StatefulWidget {
  final PageManager manager;
  final List<AppNavItem> navItems;
  final CheckoutCart cart;
  final Function onLogin;
  final Function onLogout;
  final Function onCartLookup;

  /// Abre el cambio de la contraseña propia (D14, D21).
  final Function? onChangePassword;

  /// Abre "Mi perfil".
  final VoidCallback? onProfile;

  /// Sin fondo, para ir encima de la foto de portada del inicio.
  final bool transparent;

  const ToolBar({
    super.key,
    required this.manager,
    required this.navItems,
    required this.cart,
    required this.onLogin,
    required this.onLogout,
    required this.onCartLookup,
    this.onChangePassword,
    this.onProfile,
    this.transparent = false,
  });

  @override
  State<ToolBar> createState() => ToolBarState();
}

class ToolBarState extends State<ToolBar> {
  final TextEditingController searchBarController = TextEditingController();

  @override
  void dispose() {
    searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PageManager>.value(value: widget.manager),
        ChangeNotifierProvider<SessionManager>.value(value: SessionManager()),
        ChangeNotifierProvider<CheckoutCart>.value(value: widget.cart),
      ],
      child: Consumer3<PageManager, SessionManager, CheckoutCart>(
        builder: (context, manager, sessionManager, cart, child) {
          final page = manager.currentPage;
          final wide = AppBreakpoints.isWide(context);
          final compact = AppBreakpoints.isCompact(context);
          final user = sessionManager.session.user;
          final showSearch = page is BrowsablePage && page.searchEnabled;
          // Sobre la foto de la portada los textos e íconos van siempre claros.
          final onImage = widget.transparent;

          if (page is BrowsablePage &&
              searchBarController.text != page.searchField.value) {
            searchBarController.text = page.searchField.value;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                color: widget.transparent ? Colors.transparent : AppColors.background,
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? AppSpacing.lg : AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        if (manager.isLastAvailable) ...[
                          _RoundIconButton(
                            icon: Icons.arrow_back,
                            tooltip: 'Atrás',
                            onPressed: manager.toLast,
                            onImage: onImage,
                          ),
                          const SizedBox(width: AppSpacing.md),
                        ],
                        Semantics(
                          label: 'Universidad Católica Boliviana',
                          image: true,
                          // El logo se pinta del color del texto: claro de noche
                          // y sobre la foto, oscuro de día.
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                onImage ? AppColors.onImage : AppColors.textPrimary,
                                BlendMode.srcIn),
                            child: Image.asset(
                              'assets/images/ucb_logo.png',
                              height: compact ? 30 : 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        if (wide)
                          Expanded(child: _NavLinks(items: widget.navItems, manager: manager, onImage: onImage))
                        else
                          const Spacer(),
                        if (user.can(AppPermission.registrarPrestamos)) ...[
                          _CartButton(
                            count: cart.items.length,
                            expanded: !compact,
                            onPressed: () => widget.onCartLookup(),
                            onImage: onImage,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        ThemeToggleButton(onImage: onImage),
                        const SizedBox(width: AppSpacing.sm),
                        _AccountButton(
                          user: user,
                          compact: compact,
                          onImage: onImage,
                          onLogin: () => widget.onLogin(),
                          onLogout: () => widget.onLogout(),
                          onChangePassword: widget.onChangePassword == null
                              ? null
                              : () => widget.onChangePassword!(),
                          onProfile: widget.onProfile,
                        ),
                      ],
                    ),
                    if (page is BrowsablePage &&
                        (showSearch || page.filterSet.filters.isNotEmpty)) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (showSearch)
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560),
                              child: _SearchField(
                                controller: searchBarController,
                                hint: page.searchHint,
                                onChanged: (value) => page.searchField.value = value,
                              ),
                            ),
                          for (final Filter filter in page.filterSet.filters)
                            filter is DateFilter
                                ? DropdownDateFilter(filter: filter)
                                : DropDownFilter(filter: filter),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!sessionManager.isOnline)
                Container(
                  color: AppColors.surfaceHigh,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
                  child: Text(
                    'Sin conexión con el servidor',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Enlaces del menú en la barra superior (pantallas anchas).
class _NavLinks extends StatelessWidget {
  final List<AppNavItem> items;
  final PageManager manager;
  final bool onImage;

  const _NavLinks({required this.items, required this.manager, required this.onImage});

  @override
  Widget build(BuildContext context) {
    final visible = visibleNavItems(items);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in visible)
            _NavLink(
              onImage: onImage,
              label: item.label,
              selected: manager.currentPage == item.page,
              onTap: () => manager.setPage(item.page),
            ),
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final bool selected;
  final bool onImage;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onImage,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || hovered;
    final strong = widget.onImage ? AppColors.onImage : AppColors.textPrimary;
    final soft = widget.onImage ? AppColors.onImage.withOpacity(0.78) : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: widget.selected,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (value) => setState(() => hovered = value),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
                  color: active ? strong : soft,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: widget.selected ? 24 : (hovered ? 12 : 0),
                color: strong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  const _SearchField({required this.controller, required this.onChanged, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: Color(0xFF1D1C1A), fontSize: 15),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 15),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF555555)),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool onImage;

  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.onImage,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        foregroundColor: onImage ? AppColors.onImage : AppColors.textPrimary,
        backgroundColor: onImage ? Colors.black.withOpacity(0.3) : Colors.transparent,
        side: BorderSide(color: onImage ? AppColors.onImage.withOpacity(0.5) : AppColors.border),
        fixedSize: const Size(44, 44),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  final int count;
  final bool expanded;
  final VoidCallback onPressed;
  final bool onImage;

  const _CartButton({
    required this.count,
    required this.expanded,
    required this.onPressed,
    required this.onImage,
  });

  @override
  Widget build(BuildContext context) {
    if (!expanded) {
      return Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: AppColors.primary,
        child: _RoundIconButton(
          icon: Icons.shopping_cart_outlined,
          tooltip: 'Mi préstamo ($count)',
          onPressed: onPressed,
          onImage: onImage,
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
      label: Text('Mi préstamo · $count'),
      style: OutlinedButton.styleFrom(
        foregroundColor: onImage ? AppColors.onImage : AppColors.textPrimary,
        backgroundColor: onImage ? Colors.black.withOpacity(0.3) : Colors.transparent,
        side: BorderSide(color: onImage ? AppColors.onImage.withOpacity(0.5) : AppColors.border),
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg + 2),
      ),
    );
  }
}

class _AccountButton extends StatelessWidget {
  final User user;
  final bool compact;
  final bool onImage;
  final VoidCallback onLogin;
  final VoidCallback onLogout;
  final VoidCallback? onChangePassword;
  final VoidCallback? onProfile;

  const _AccountButton({
    required this.user,
    required this.compact,
    required this.onImage,
    required this.onLogin,
    required this.onLogout,
    this.onChangePassword,
    this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    // Botón invertido: claro sobre la foto y de noche, oscuro de día.
    final fill = onImage ? AppColors.onImage : AppColors.textPrimary;
    final ink = onImage ? const Color(0xFF111111) : AppColors.surfaceHigh;
    if (user is VisitorUser) {
      if (compact) {
        return IconButton(
          onPressed: onLogin,
          tooltip: 'Iniciar sesión',
          icon: const Icon(Icons.person_outline),
          style: IconButton.styleFrom(
            backgroundColor: fill,
            foregroundColor: ink,
            fixedSize: const Size(44, 44),
          ),
        );
      }
      return FilledButton(
        onPressed: onLogin,
        style: FilledButton.styleFrom(
          backgroundColor: fill,
          foregroundColor: ink,
          shape: const StadiumBorder(),
          minimumSize: const Size(0, 44),
        ),
        child: const Text('Iniciar sesión'),
      );
    }

    return PopupMenuButton<String>(
      tooltip: 'Mi cuenta',
      offset: const Offset(0, 52),
      onSelected: (value) {
        if (value == 'profile') onProfile?.call();
        if (value == 'password') onChangePassword?.call();
        if (value == 'logout') onLogout();
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name,
                  style: TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
              Text(user.roles.join(', '),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        if (onProfile != null)
          const PopupMenuItem<String>(
            value: 'profile',
            child: ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Mi perfil'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onChangePassword != null)
          const PopupMenuItem<String>(
            value: 'password',
            child: ListTile(
              leading: Icon(Icons.key_outlined),
              title: Text('Cambiar contraseña'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar sesión'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
        ),
        child: Text(
          userInitials(user),
          style: TextStyle(
            color: ink,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
