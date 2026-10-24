import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/HomePage.dart';
import 'package:frontend/services/Cart.dart';
import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/app_nav.dart';
import 'package:frontend/widgets/tool_bar.dart';
import '../services/PageManager.dart';

class PageContainer extends StatefulWidget {
  final PageManager manager;
  final List<AppNavItem> navItems;
  final CheckoutCart cart;
  final Function onLogin;
  final Function onLogout;
  final Function onCartLookup;

  /// Abre el cambio de la contraseña propia (D14, D21).
  final Function? onChangePassword;

  const PageContainer({
    super.key,
    required this.manager,
    required this.navItems,
    required this.cart,
    required this.onLogin,
    required this.onLogout,
    required this.onCartLookup,
    this.onChangePassword,
  });

  @override
  State<StatefulWidget> createState() => PageContainerState();
}

class PageContainerState extends State<PageContainer> {
  /// En el inicio la barra va transparente sobre la portada y se oscurece
  /// cuando el contenido se desplaza bajo ella.
  bool scrolledPastHero = false;

  ToolBar _toolBar({bool transparent = false}) => ToolBar(
        manager: widget.manager,
        navItems: widget.navItems,
        cart: widget.cart,
        onLogin: widget.onLogin,
        onLogout: widget.onLogout,
        onCartLookup: widget.onCartLookup,
        onChangePassword: widget.onChangePassword,
        transparent: transparent,
      );

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final past = notification.metrics.pixels > 40;
    if (past != scrolledPastHero) setState(() => scrolledPastHero = past);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.manager),
      ],
      child: Consumer<PageManager>(
        builder: (context, manager, snapshot) {
          final page = manager.currentPage;

          if (page is HomePage) {
            return Stack(
              children: [
                Positioned.fill(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
                    child: page,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _toolBar(transparent: !scrolledPastHero),
                ),
              ],
            );
          }

          final compact = AppBreakpoints.isCompact(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _toolBar(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                    compact ? AppSpacing.sm : AppSpacing.lg,
                    0,
                    compact ? AppSpacing.sm : AppSpacing.lg,
                    compact ? AppSpacing.sm : AppSpacing.lg,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: page,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
