import "dart:ui";


import "package:flutter/material.dart";
import "package:frontend/screens/PageBase.dart";
import "package:frontend/screens/ChangePasswordPage.dart";
import "package:frontend/screens/PasswordLinkPage.dart";
import "package:frontend/screens/PasswordReset.dart";
import "package:frontend/screens/category_brand_screen.dart";
import "package:frontend/screens/create_item_screen.dart";
import "package:frontend/screens/create_user.dart";
import "package:frontend/services/Cart.dart";
import "package:frontend/widgets/CheckoutCartList.dart";
import "package:frontend/widgets/item_info.dart";
import 'package:provider/provider.dart';

import "package:frontend/models/Session.dart";
import "package:frontend/screens/HomePage.dart";
import "package:frontend/services/ContextMessageService.dart";
import "package:frontend/themes/AppTheme.dart";
import "package:frontend/widgets/app_nav.dart";

import "../models/Item.dart";
import "../models/Permissions.dart";
import "../models/User.dart";
import "../services/PageManager.dart";



import "../services/SelectedItemContext.dart";
import "LoginPage.dart";
import "PageContainer.dart";
import "SearchItemPage.dart";
import "SearchLoanPage.dart";
import "SearchUserPage.dart";
import "SecurityEventsPage.dart";
import "RolesPage.dart";

class MainFrame extends StatefulWidget {
  ContextMessageService messageService;
  MainFrame({super.key, required this.messageService});

  @override
  State<MainFrame> createState() {
    return MainFrameState();
  }
}

class MainFrameState extends State<MainFrame> {
  bool onLogin = false;
  bool onPasswordReset = false;
  bool onChangePassword = false;

  /// Token de un enlace de restablecimiento (D24): la aplicación web se abre
  /// con ?enlace=<token> y muestra la página para elegir la contraseña.
  String? linkToken = Uri.base.queryParameters['enlace'];

  late HomePage homePage;
  late SearchItemPage searchItemPage;
  late SearchUserPage searchUserPage;
  late SecurityEventsPage securityEventsPage;
  late RolesPage rolesPage;
  late SearchLoanPage searchLoanPage;
  late CreateItemScreen createItemPage;
  late CategoryBrandScreen categoryBrandPage;
  late CreateUserScreen createUserPage;
  late ItemInfoWidget sidePanel;

  late PageManager pageManager;
  late PageContainer pageContainer;
  late List<AppNavItem> navItems;
  late CheckoutCartList cartList;

  SelectedItemContext selectedItem = SelectedItemContext();
  CheckoutCart cart = CheckoutCart();

  MainFrameState() {
    homePage = HomePage(
      selectedItem: selectedItem,
      onSearch: _searchItems,
      onCategory: _browseCategory,
    );
    searchItemPage = SearchItemPage(selectedItem: selectedItem);
    searchUserPage = SearchUserPage();
    securityEventsPage = SecurityEventsPage();
    rolesPage = RolesPage();
    searchLoanPage = SearchLoanPage();
    createItemPage = CreateItemScreen();
    categoryBrandPage = CategoryBrandScreen();
    createUserPage = CreateUserScreen();
    pageManager = PageManager(defaultPage: homePage);
    cartList = CheckoutCartList(cart: cart);

    navItems = [
      AppNavItem(
        label: 'Inicio',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        page: homePage,
      ),
      AppNavItem(
        label: 'Equipos',
        icon: Icons.biotech_outlined,
        selectedIcon: Icons.biotech,
        page: searchItemPage,
      ),
      AppNavItem(
        label: 'Préstamos',
        icon: Icons.swap_horiz_outlined,
        selectedIcon: Icons.swap_horiz,
        page: searchLoanPage,
        permission: AppPermission.registrarPrestamos,
      ),
      AppNavItem(
        label: 'Marcas y categorías',
        icon: Icons.category_outlined,
        selectedIcon: Icons.category,
        page: categoryBrandPage as PageBase,
        // El asistente ya no ve esta opción, que el servidor le rechazaba.
        permission: AppPermission.gestionarInventario,
      ),
      AppNavItem(
        label: 'Usuarios',
        icon: Icons.people_outline,
        selectedIcon: Icons.people,
        page: searchUserPage,
        permission: AppPermission.verUsuarios,
      ),
      AppNavItem(
        label: 'Roles',
        icon: Icons.badge_outlined,
        selectedIcon: Icons.badge,
        page: rolesPage,
        // Gestión de roles y sus permisos (D15).
        permission: AppPermission.verRoles,
      ),
      AppNavItem(
        label: 'Bitácora',
        icon: Icons.shield_outlined,
        selectedIcon: Icons.shield,
        page: securityEventsPage,
        permission: AppPermission.verBitacoras,
      ),
    ];

    pageContainer = PageContainer(
      manager: pageManager,
      navItems: navItems,
      cart: cart,
      onLogin: _openLogin,
      onLogout: _logout,
      onChangePassword: _openChangePassword,
      onCartLookup: _openCart,
    );
    sidePanel = ItemInfoWidget(
        itemContext: selectedItem,
        pageManager: pageManager,
        cart: cart);
  }

  void _openLogin() => setState(() => onLogin = true);

  void _closeAuth() => setState(() {
        onLogin = false;
        onPasswordReset = false;
      });

  void _openChangePassword() => setState(() => onChangePassword = true);

  Future<void> _logout() async {
    await SessionManager().logOut();
    pageManager.clear();
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      builder: (context) => cartList,
    );
  }

  void _searchItems(String text) {
    searchItemPage.searchField.value = text;
    pageManager.setPage(searchItemPage);
  }

  Future<void> _browseCategory(Category category) async {
    final filter = searchItemPage.categoryFilter;
    await filter.getItems();
    filter.clearSelected();
    // El filtro compara por instancia: se busca la categoría por su id.
    for (final c in filter.items) {
      if (c.id == category.id) filter.select(c);
    }
    searchItemPage.searchField.value = '';
    pageManager.setPage(searchItemPage);
  }

  /// Panel con el detalle del equipo elegido. En pantallas anchas va acoplado
  /// a la derecha; en las angostas ocupa toda la pantalla.
  Widget _itemPanel({required bool docked}) {
    return Container(
      width: docked ? 400 : double.infinity,
      margin: docked
          ? const EdgeInsets.fromLTRB(0, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg)
          : EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSpacing.lg + 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(docked ? AppRadius.lg : 0),
      ),
      child: SafeArea(child: sidePanel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = AppBreakpoints.isWide(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: pageManager),
        ChangeNotifierProvider.value(value: selectedItem),
        ChangeNotifierProvider.value(value: cart),
        ChangeNotifierProvider.value(value: SessionManager()),
      ],
      child: Consumer4<PageManager, SelectedItemContext, CheckoutCart, SessionManager>(
        builder: (context, manager, selection, cart, sessionManager, child) {
          final itemOpen = selection.isSet();
          final user = sessionManager.session.user;

          return Stack(
            children: [
              Container(
                color: AppColors.background,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: pageContainer),
                    if (wide)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: itemOpen ? _itemPanel(docked: true) : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
              if (!wide)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: AppSpacing.lg + 2,
                  child: SafeArea(
                    top: false,
                    child: Center(
                      child: BottomNavPill(
                        items: navItems,
                        manager: manager,
                        cartCount: cart.items.length,
                        showCart: user.can(AppPermission.registrarPrestamos),
                        onCart: _openCart,
                        onMore: () => showMoreSheet(
                          context: context,
                          items: visibleNavItems(navItems),
                          manager: manager,
                          onLogin: _openLogin,
                          onLogout: _logout,
                          onChangePassword: _openChangePassword,
                        ),
                      ),
                    ),
                  ),
                ),
              if (!wide && itemOpen) Positioned.fill(child: _itemPanel(docked: false)),
              if (onLogin || onPasswordReset || linkToken != null)
                GestureDetector(
                  onTapDown: (e) => _closeAuth(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                    child: Container(color: Colors.black.withOpacity(0.6)),
                  ),
                ),
              if (onLogin) LoginScreen(
                onSubmit: (username, password) async {
                  await SessionManager().login(username, password);
                  if (SessionManager().session.user.username ==
                      username.trim().toLowerCase()) {
                    setState(() => onLogin = false);
                  }
                },
                onPasswordReset: () {
                  setState(() {
                    onLogin = false;
                    onPasswordReset = true;
                  });
                },
                onClose: _closeAuth,
              ),
              if (onPasswordReset) RecuperarContrasenaScreen(
                onClose: _closeAuth,
                onBack: () {
                  setState(() {
                    onPasswordReset = false;
                    onLogin = true;
                  });
                },
              ),
              if (linkToken != null) PasswordLinkScreen(
                token: linkToken!,
                onDone: () {
                  setState(() {
                    linkToken = null;
                    onLogin = true;
                  });
                },
              ),
              // Cambio de la contraseña propia: obligatorio si venció (D21),
              // voluntario desde la barra superior.
              Consumer<SessionManager>(
                builder: (context, sessionManager, child) {
                  final user = sessionManager.session.user;
                  final forced = user is! VisitorUser && user.passwordExpired;
                  if (!forced && !onChangePassword) return const SizedBox.shrink();
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      ChangePasswordScreen(
                        forced: forced,
                        onDone: () {
                          setState(() {onChangePassword = false;});
                        },
                        onLogout: () async {
                          setState(() {onChangePassword = false;});
                          await SessionManager().logOut();
                          pageManager.clear();
                        },
                      ),
                    ],
                  );
                },
              ),


              MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(value: widget.messageService),
                ],
                child: Consumer<ContextMessageService>(
                  builder: (context, messageService, child){
                    final messageView = messageService.notification;
                    if(messageView != null && messageService.displaying){
                      return  messageView;
                    }
                    return Container();
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
