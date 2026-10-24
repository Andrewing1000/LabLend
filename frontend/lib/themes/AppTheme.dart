import 'package:flutter/material.dart';

/// Colores de un modo (noche o día). Los dos modos usan los mismos nombres,
/// así cada pantalla se adapta sola al cambiar de modo.
class AppPalette {
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color surfaceHighest;
  final Color border;
  final Color primary;
  final Color onPrimary;
  final Color primaryMuted;
  final Color success;
  final Color warning;
  final Color error;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.surfaceHighest,
    required this.border,
    required this.primary,
    required this.onPrimary,
    required this.primaryMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  /// Noche: neutros cálidos casi negros; las diferencias entre fondos son
  /// pequeñas a propósito, la jerarquía la dan el texto y el espacio.
  static const night = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF0B0B0B),
    surface: Color(0xFF141414),
    surfaceHigh: Color(0xFF1B1B1B),
    surfaceHighest: Color(0xFF242424),
    border: Color(0xFF2C2C2C),
    primary: Color(0xFF7FA6D9),
    onPrimary: Color(0xFF0E1116),
    primaryMuted: Color(0xFF34465E),
    success: Color(0xFF8FB59A),
    warning: Color(0xFFCFAE79),
    error: Color(0xFFD08B85),
    textPrimary: Color(0xFFECECEC),
    textSecondary: Color(0xFFA6A6A6),
    textMuted: Color(0xFF808080),
  );

  /// Día: papel cálido en lugar de blanco puro, tinta casi negra y los
  /// mismos acentos un poco más oscuros para que se lean sobre fondo claro.
  static const day = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF2F0EB),
    surface: Color(0xFFF8F7F3),
    surfaceHigh: Color(0xFFFFFFFF),
    surfaceHighest: Color(0xFFEAE7E0),
    border: Color(0xFFDDD9D1),
    primary: Color(0xFF3C679E),
    onPrimary: Color(0xFFFFFFFF),
    primaryMuted: Color(0xFFD6E0EC),
    success: Color(0xFF4F7E5C),
    warning: Color(0xFF9A7334),
    error: Color(0xFFA9554F),
    textPrimary: Color(0xFF1D1C1A),
    textSecondary: Color(0xFF5C5953),
    textMuted: Color(0xFF85817A),
  );
}

/// Colores del modo actual. Los widgets los toman de aquí (o de
/// Theme.of(context)) en lugar de escribir Colors.xxx a mano.
class AppColors {
  static AppPalette current = AppPalette.night;

  static Color get background => current.background;
  static Color get surface => current.surface;
  static Color get surfaceHigh => current.surfaceHigh;
  static Color get surfaceHighest => current.surfaceHighest;
  static Color get border => current.border;
  static Color get primary => current.primary;
  static Color get onPrimary => current.onPrimary;
  static Color get primaryMuted => current.primaryMuted;
  static Color get success => current.success;
  static Color get warning => current.warning;
  static Color get error => current.error;
  static Color get textPrimary => current.textPrimary;
  static Color get textSecondary => current.textSecondary;
  static Color get textMuted => current.textMuted;

  /// Texto e íconos sobre fotos (la portada): siempre claros, en los dos
  /// modos, porque la foto lleva un velo oscuro.
  static const Color onImage = Color(0xFFF4F4F2);
}

/// Escala de espaciado (múltiplos de 4).
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Radios de borde.
class AppRadius {
  static const double sm = 6;
  static const double md = 12;
  static const double lg = 20;
  static const double pill = 200;
}

/// Anchos de pantalla en los que cambia la estructura de la aplicación.
class AppBreakpoints {
  /// Por debajo: diseño de celular (textos y márgenes más chicos).
  static const double compact = 700;

  /// Desde aquí: menú en la barra superior y panel del equipo acoplado a la
  /// derecha. Por debajo: menú inferior y panel del equipo a pantalla completa.
  static const double wide = 1100;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wide;
}

class AppTheme {
  static const String _font = 'Metropolis';

  /// Tema del modo actual (se vuelve a construir al cambiar de modo).
  static ThemeData get darkTheme => build();

  static ThemeData build() {
    final p = AppColors.current;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: p.brightness,
    ).copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: p.primary,
      onSecondary: p.onPrimary,
      error: p.error,
      onError: p.surfaceHigh,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surfaceHigh,
      surfaceContainerHigh: p.surfaceHigh,
      surfaceContainerHighest: p.surfaceHighest,
      outline: p.border,
      outlineVariant: p.border,
    );

    // Con la fuente puesta en cada estilo: los botones y campos los usan
    // directamente y, sin ella, caían en Roboto.
    final textTheme = TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w900, fontSize: 40, color: p.textPrimary),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: p.textPrimary),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 25, color: p.textPrimary),
      titleSmall: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: p.textPrimary),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: p.textPrimary),
      bodyMedium: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: p.textPrimary),
      bodySmall: TextStyle(fontWeight: FontWeight.w300, fontSize: 12, color: p.textSecondary),
      labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: p.textPrimary),
      labelMedium: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: p.textMuted),
      labelSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: p.textMuted),
    ).apply(fontFamily: _font);

    final buttonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md));
    const buttonPadding =
        EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: colorScheme,
      primaryColor: p.primary,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.surface,
      fontFamily: _font,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: p.textPrimary),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.surfaceHighest,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          disabledBackgroundColor: p.surfaceHighest,
          disabledForegroundColor: p.textMuted,
          elevation: 0,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textPrimary,
          side: BorderSide(color: p.border),
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        hintStyle: textTheme.labelMedium,
        labelStyle: textTheme.labelMedium,
        floatingLabelStyle: TextStyle(color: p.primary),
        errorStyle: TextStyle(color: p.error, fontSize: 12),
        border: inputBorder(p.border),
        enabledBorder: inputBorder(p.border),
        focusedBorder: inputBorder(p.primary, 1.5),
        errorBorder: inputBorder(p.error),
        focusedErrorBorder: inputBorder(p.error, 1.5),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md + 2)),
        titleTextStyle: textTheme.titleSmall,
        contentTextStyle: textTheme.bodyLarge,
      ),
      cardTheme: CardThemeData(
        color: p.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.surfaceHighest,
        contentTextStyle: textTheme.bodyLarge,
        actionTextColor: p.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.textPrimary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: TextStyle(fontFamily: _font, fontSize: 12, color: p.surfaceHigh),
        waitDuration: const Duration(milliseconds: 400),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surfaceHigh,
        surfaceTintColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? p.onPrimary : p.textMuted),
        trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? p.primary : p.surfaceHighest),
      ),
    );
  }
}
