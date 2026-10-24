import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Session.dart';
import '../models/Item.dart';
import '../services/SelectedItemContext.dart';
import '../themes/AppTheme.dart';
import '../widgets/equipment_card.dart';
import '../widgets/footer_widget.dart';
import '../widgets/typewriter_text.dart';
import 'PageBase.dart';

class HomePage extends PageBase {
  ScrollController? scrollController;
  late HomeSections sections;
  SelectedItemContext selectedItem;

  /// Lleva la búsqueda de la portada a la página de equipos.
  final ValueChanged<String>? onSearch;

  /// Abre la página de equipos filtrada por una categoría.
  final ValueChanged<Category>? onCategory;

  HomePage({
    super.key,
    super.manager,
    super.child,
    this.scrollController,
    required this.selectedItem,
    this.onSearch,
    this.onCategory,
    HomeSections? sections,
  }) : super(disposable: false) {
    this.sections = sections ?? HomeSections();
    scrollController ??= ScrollController();
  }

  @override
  State<StatefulWidget> createState() => HomePageState();

  @override
  void onDispose() async {}

  @override
  void onSet() {}

  void toTop() {
    scrollController?.animateTo(scrollController!.position.minScrollExtent,
        duration: const Duration(milliseconds: 400), curve: Curves.decelerate);
  }

  void toBottom() {
    scrollController?.animateTo(scrollController!.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400), curve: Curves.decelerate);
  }
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeSections>.value(
      value: widget.sections,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < AppBreakpoints.compact;
          final gutter = compact ? AppSpacing.lg + 4 : 56.0;

          return SingleChildScrollView(
            controller: widget.scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Hero(
                  compact: compact,
                  width: constraints.maxWidth,
                  // La portada ocupa toda la pantalla al entrar.
                  height: constraints.maxHeight.isFinite
                      ? constraints.maxHeight.clamp(compact ? 430.0 : 560.0, double.infinity)
                      : (compact ? 430.0 : 560.0),
                  gutter: gutter,
                  onSearch: widget.onSearch,
                ),
                Consumer<HomeSections>(
                  builder: (context, sections, child) {
                    if (sections.loading) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.xxl * 2),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (sections.items.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(gutter, 56, gutter, 56),
                        child: Text(
                          'Todavía no hay equipos para mostrar.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (sections.categories.isNotEmpty)
                          _CategorySection(
                            sections: sections,
                            compact: compact,
                            gutter: gutter,
                            onCategory: widget.onCategory,
                            onSeeAll: () => widget.onSearch?.call(''),
                          ),
                        for (final rail in sections.rails)
                          _Rail(
                            title: rail.title,
                            items: rail.items,
                            compact: compact,
                            gutter: gutter,
                            onTap: widget.selectedItem.setItem,
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                FooterWidget(compact: compact, gutter: gutter),
                // Espacio para el menú inferior en pantallas angostas.
                SizedBox(height: AppBreakpoints.isWide(context) ? 0 : 96),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Hero extends StatefulWidget {
  final bool compact;
  final double width;
  final double height;
  final double gutter;
  final ValueChanged<String>? onSearch;

  const _Hero({
    required this.compact,
    required this.width,
    required this.height,
    required this.gutter,
    this.onSearch,
  });

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _search() => widget.onSearch?.call(controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final titleSize = compact ? 52.0 : (widget.width * 0.075).clamp(64.0, 104.0);

    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
            semanticLabel:
                'Edificio del laboratorio de la Universidad Católica Boliviana al anochecer',
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          // En pantallas angostas el menú inferior ocupa este lugar.
          if (AppBreakpoints.isWide(context))
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.lg,
              child: Center(
                child: IconButton(
                  tooltip: 'Ver equipos',
                  onPressed: () => Scrollable.maybeOf(context)?.position.animateTo(
                        widget.height,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                widget.gutter,
                // Deja libre la barra superior arriba y, abajo, la flecha
                // (escritorio) o el menú inferior (celular).
                80,
                widget.gutter,
                AppBreakpoints.isWide(context) ? 80 : 112),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'UNIVERSIDAD CATÓLICA BOLIVIANA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 11 : 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: compact ? 2 : 3,
                    color: const Color(0xFFDADADA),
                  ),
                ),
                SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
                Semantics(
                  header: true,
                  label: 'Laboratorio UCB',
                  excludeSemantics: true,
                  child: TypewriterText(
                    text: 'Laboratorio\nUCB',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize,
                      height: 1.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -titleSize * 0.03,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Container(
                    height: compact ? 52 : 64,
                    padding: EdgeInsets.only(left: AppSpacing.lg + 2, right: compact ? AppSpacing.lg : 8),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Color(0xFF555555)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            onSubmitted: (_) => _search(),
                            textInputAction: TextInputAction.search,
                            cursorColor: AppColors.primary,
                            style: TextStyle(
                                color: AppColors.background, fontSize: compact ? 15 : 17),
                            decoration: InputDecoration(
                              hintText: '¿Qué equipo necesitas?',
                              hintStyle: TextStyle(
                                  color: const Color(0xFF666666), fontSize: compact ? 15 : 17),
                              filled: false,
                              isCollapsed: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        if (!compact)
                          FilledButton(
                            onPressed: _search,
                            style: FilledButton.styleFrom(
                              shape: const StadiumBorder(),
                              minimumSize: const Size(0, 48),
                            ),
                            child: const Text('Buscar'),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool compact;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.compact,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: TextStyle(
                fontSize: compact ? 24 : 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final HomeSections sections;
  final bool compact;
  final double gutter;
  final ValueChanged<Category>? onCategory;
  final VoidCallback onSeeAll;

  const _CategorySection({
    required this.sections,
    required this.compact,
    required this.gutter,
    required this.onSeeAll,
    this.onCategory,
  });

  @override
  Widget build(BuildContext context) {
    final tileWidth = compact ? 160.0 : 300.0;
    final tileHeight = compact ? 200.0 : 260.0;

    return Padding(
      padding: EdgeInsets.only(top: compact ? AppSpacing.xl : 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            child: _SectionHeader(
              title: 'Explora por área',
              compact: compact,
              actionLabel: compact ? 'Ver todo' : 'Todas las categorías',
              onAction: onSeeAll,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: tileHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: gutter),
              itemCount: sections.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.lg),
              itemBuilder: (context, index) {
                final category = sections.categories[index];
                return CategoryTile(
                  name: category.nombre,
                  imageUrl: sections.imageFor(category),
                  width: tileWidth,
                  height: tileHeight,
                  onTap: () => onCategory?.call(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  final String title;
  final List<Item> items;
  final bool compact;
  final double gutter;
  final ValueChanged<Item> onTap;

  const _Rail({
    required this.title,
    required this.items,
    required this.compact,
    required this.gutter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = compact ? 170.0 : 240.0;

    return Padding(
      padding: EdgeInsets.only(top: compact ? AppSpacing.xl : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            child: _SectionHeader(title: title, compact: compact),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            // Foto cuadrada + nombre + estado
            height: cardWidth + 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: gutter),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xl - 4),
              itemBuilder: (context, index) => EquipmentCard(
                item: items[index],
                width: cardWidth,
                onTap: () => onTap(items[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeRail {
  final String title;
  final List<Item> items;
  const HomeRail(this.title, this.items);
}

/// Datos del inicio: equipos, categorías y las filas que se arman con ellos.
class HomeSections extends ChangeNotifier {
  bool loading = true;
  List<Item> items = [];
  List<Category> categories = [];
  List<HomeRail> rails = [];

  /// [loader] reemplaza la consulta al servidor (lo usan las vistas previas).
  HomeSections({Future<(List<Item>, List<Category>)> Function()? loader}) {
    _load(loader ?? _fetch);
  }

  static Future<(List<Item>, List<Category>)> _fetch() async {
    return (
      await SessionManager.inventory.getItems(),
      await SessionManager.inventory.getCategories(),
    );
  }

  Future<void> _load(Future<(List<Item>, List<Category>)> Function() loader) async {
    try {
      final (loadedItems, allCategories) = await loader();
      items = loadedItems;
      // Solo las categorías que tienen equipos, para no mostrar mosaicos vacíos.
      categories = allCategories
          .where((c) => items.any((i) => i.categories.any((ic) => ic.id == c.id)))
          .take(8)
          .toList();
    } catch (_) {
      items = [];
      categories = [];
    }

    final pool = List<Item>.from(items);
    List<Item> pick() => (pool..shuffle()).take(8).toList();
    rails = [
      HomeRail('Más buscados', pick()),
      HomeRail('Nuevos', pick()),
      HomeRail('Recomendados', pick()),
    ];

    loading = false;
    notifyListeners();
  }

  /// Foto de la categoría: la del primer equipo de esa categoría que tenga una.
  String? imageFor(Category category) {
    for (final item in items) {
      if (item.imagePath != null && item.categories.any((c) => c.id == category.id)) {
        return item.imagePath;
      }
    }
    return null;
  }
}
