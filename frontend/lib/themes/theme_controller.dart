import 'dart:ui' as ui;
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/themes/AppTheme.dart';

/// Modo noche o día. Recuerda la elección del usuario en el dispositivo; la
/// primera vez sigue la preferencia del sistema operativo.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const _storage = FlutterSecureStorage();
  static const _key = 'lablend_modo';

  /// Lo registra [ThemeTransitionHost] para animar el cambio.
  Future<void> Function(Offset origin, AppPalette next)? _animateTo;

  bool get isNight => AppColors.current.brightness == Brightness.dark;

  /// Elige el modo antes de dibujar la aplicación, sin animación.
  Future<void> load(Brightness system) async {
    String? saved;
    try {
      saved = await _storage.read(key: _key);
    } catch (_) {
      // Sin almacenamiento disponible: se usa la preferencia del sistema.
    }
    final night = saved == null ? system == Brightness.dark : saved == 'noche';
    AppColors.current = night ? AppPalette.night : AppPalette.day;
  }

  /// Cambia de modo. [origin] es el punto de la pantalla desde donde se
  /// expande el modo nuevo (normalmente, el botón que se tocó).
  Future<void> toggle({Offset? origin}) async {
    final next = isNight ? AppPalette.day : AppPalette.night;
    final animate = _animateTo;
    if (animate != null) {
      await animate(origin ?? Offset.zero, next);
    } else {
      apply(next);
    }
    try {
      await _storage.write(key: _key, value: next == AppPalette.night ? 'noche' : 'dia');
    } catch (_) {}
  }

  void apply(AppPalette palette) {
    AppColors.current = palette;
    notifyListeners();
  }
}

/// Envuelve la aplicación y anima el cambio de modo con un fundido suave:
/// la pantalla anterior se desvanece y debajo ya está el modo nuevo.
///
/// Para que sea liviano hasta en equipos viejos, la imagen de la pantalla
/// anterior se toma en baja resolución (mientras se desvanece no se nota) y
/// el fundido es una sola capa de opacidad.
class ThemeTransitionHost extends StatefulWidget {
  final WidgetBuilder builder;
  const ThemeTransitionHost({super.key, required this.builder});

  @override
  State<ThemeTransitionHost> createState() => _ThemeTransitionHostState();
}

class _ThemeTransitionHostState extends State<ThemeTransitionHost>
    with SingleTickerProviderStateMixin {
  final GlobalKey _boundaryKey = GlobalKey();
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final Animation<double> _fade = Tween(begin: 1.0, end: 0.0)
      .chain(CurveTween(curve: Curves.easeInOut))
      .animate(_controller);

  ui.Image? _previous;

  /// Resolución de la imagen anterior, en píxeles por punto lógico.
  static const double _snapshotScale = 0.6;

  @override
  void initState() {
    super.initState();
    ThemeController.instance._animateTo = _animateTo;
    ThemeController.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeController.instance._animateTo = null;
    ThemeController.instance.removeListener(_onThemeChanged);
    _controller.dispose();
    _previous?.dispose();
    super.dispose();
  }

  /// Los colores se leen de [AppColors] al construir cada widget, así que al
  /// cambiar de modo se reconstruye todo el árbol, también las páginas que la
  /// aplicación guarda en memoria. Ocurre debajo de la imagen anterior.
  void _onThemeChanged() {
    setState(() {});
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }

  Future<void> _animateTo(Offset origin, AppPalette next) async {
    if (_controller.isAnimating || _previous != null) return;
    final boundary =
        _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (PlatformDispatcher.instance.accessibilityFeatures.disableAnimations ||
        boundary == null) {
      ThemeController.instance.apply(next);
      return;
    }

    ui.Image image;
    try {
      image = await boundary.toImage(pixelRatio: _snapshotScale);
    } catch (_) {
      ThemeController.instance.apply(next);
      return;
    }
    if (!mounted) return;

    // En el mismo cuadro: la imagen anterior tapa la pantalla y el modo
    // cambia debajo; después la imagen se desvanece.
    setState(() => _previous = image);
    ThemeController.instance.apply(next);
    await _controller.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _previous?.dispose();
      _previous = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(key: _boundaryKey, child: widget.builder(context)),
          if (_previous != null)
            IgnorePointer(
              child: FadeTransition(
                opacity: _fade,
                child: RawImage(
                  image: _previous,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Botón de sol y luna para cambiar de modo. La animación sale desde el
/// centro del botón.
class ThemeToggleButton extends StatelessWidget {
  /// Sobre la foto de la portada el ícono va siempre claro.
  final bool onImage;
  const ThemeToggleButton({super.key, this.onImage = false});

  @override
  Widget build(BuildContext context) {
    final night = ThemeController.instance.isNight;
    final color = onImage ? AppColors.onImage : AppColors.textPrimary;

    return IconButton(
      tooltip: night ? 'Modo día' : 'Modo noche',
      onPressed: () {
        final box = context.findRenderObject() as RenderBox?;
        final center = box == null
            ? null
            : box.localToGlobal(box.size.center(Offset.zero));
        ThemeController.instance.toggle(origin: center);
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween(begin: 0.75, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          night ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          key: ValueKey(night),
          color: color,
          size: 22,
        ),
      ),
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        side: BorderSide(
          color: onImage ? AppColors.onImage.withOpacity(0.5) : AppColors.border,
        ),
        backgroundColor: onImage ? Colors.black.withOpacity(0.3) : Colors.transparent,
      ),
    );
  }
}
