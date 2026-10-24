import 'package:flutter/material.dart';

/// Paleta única de la aplicación. Los widgets deben tomar sus colores de aquí
/// (o de Theme.of(context)) en lugar de escribir Colors.xxx a mano.
class AppColors {
  // Neutros cálidos, del más profundo al más elevado. Las diferencias son
  // pequeñas a propósito: la jerarquía la dan el texto y el espacio.
  static const Color background = Color(0xFF0B0B0B);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceHigh = Color(0xFF1B1B1B);
  static const Color surfaceHighest = Color(0xFF242424);
  static const Color border = Color(0xFF2C2C2C);

  // Acento: un azul apagado que se usa poco (acción principal, selección).
  static const Color primary = Color(0xFF7FA6D9);
  static const Color onPrimary = Color(0xFF0E1116);
  // Azul más oscuro para superficies grandes, donde el acento cansa
  static const Color primaryMuted = Color(0xFF34465E);

  // Estados, desaturados: informan sin llamar la atención.
  static const Color success = Color(0xFF8FB59A);
  static const Color warning = Color(0xFFCFAE79);
  static const Color error = Color(0xFFD08B85);

  // Texto: blanco roto en lugar de blanco puro.
  static const Color textPrimary = Color(0xFFECECEC);
  static const Color textSecondary = Color(0xFFA6A6A6);
  static const Color textMuted = Color(0xFF808080);
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

  static final ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.primary,
    onSecondary: AppColors.onPrimary,
    error: AppColors.error,
    onError: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainerLowest: AppColors.background,
    surfaceContainerLow: AppColors.surface,
    surfaceContainer: AppColors.surfaceHigh,
    surfaceContainerHigh: AppColors.surfaceHigh,
    surfaceContainerHighest: AppColors.surfaceHighest,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
  );

  // Con la fuente puesta en cada estilo: los botones y campos los usan
  // directamente y, sin ella, caían en Roboto.
  static final TextTheme _textTheme = const TextTheme(
    headlineLarge: TextStyle(fontWeight: FontWeight.w900, fontSize: 40, color: AppColors.textPrimary),
    titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: AppColors.textPrimary),
    titleMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 25, color: AppColors.textPrimary),
    titleSmall: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.textPrimary),

    bodyLarge: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: AppColors.textPrimary),
    bodySmall: TextStyle(fontWeight: FontWeight.w300, fontSize: 12, color: AppColors.textSecondary),

    labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
    labelMedium: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: AppColors.textMuted),
    labelSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.textMuted),
  ).apply(fontFamily: _font);

  static final RoundedRectangleBorder _buttonShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md));

  static const EdgeInsets _buttonPadding =
      EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md);

  static OutlineInputBorder _inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _colorScheme,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.surface,
    fontFamily: _font,
    textTheme: _textTheme,

    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.surfaceHighest,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.surfaceHighest,
        disabledForegroundColor: AppColors.textMuted,
        elevation: 0,
        padding: _buttonPadding,
        shape: _buttonShape,
        textStyle: _textTheme.labelLarge,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        padding: _buttonPadding,
        shape: _buttonShape,
        textStyle: _textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: _buttonPadding,
        shape: _buttonShape,
        textStyle: _textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: _buttonShape,
        textStyle: _textTheme.labelLarge,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      hintStyle: _textTheme.labelMedium,
      labelStyle: _textTheme.labelMedium,
      floatingLabelStyle: const TextStyle(color: AppColors.primary),
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
      border: _inputBorder(AppColors.border),
      enabledBorder: _inputBorder(AppColors.border),
      focusedBorder: _inputBorder(AppColors.primary, 2),
      errorBorder: _inputBorder(AppColors.error),
      focusedErrorBorder: _inputBorder(AppColors.error, 2),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      titleTextStyle: _textTheme.titleSmall,
      contentTextStyle: _textTheme.bodyLarge,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surfaceHighest,
      contentTextStyle: _textTheme.bodyLarge,
      actionTextColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.surfaceHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      textStyle: const TextStyle(fontFamily: _font, fontSize: 12, color: AppColors.textPrimary),
      waitDuration: const Duration(milliseconds: 400),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.surfaceHigh,
      surfaceTintColor: Colors.transparent,
      textStyle: _textTheme.bodyMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  );
}
