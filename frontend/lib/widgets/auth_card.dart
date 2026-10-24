import 'package:flutter/material.dart';
import 'package:frontend/themes/AppTheme.dart';

/// Tarjeta centrada de las pantallas de acceso (inicio de sesión y
/// contraseñas): ícono, título, texto de apoyo y el contenido. Se adapta al
/// ancho de la pantalla y se desplaza si no entra en alto.
class AuthCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  /// Color del círculo del ícono (por defecto, el azul de marca).
  final Color accent;

  /// Si se da, muestra la X para cerrar la tarjeta.
  final VoidCallback? onClose;

  const AuthCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.accent = AppColors.primary,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Material(
            color: AppColors.surfaceHigh,
            elevation: 12,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md + 2),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(compact ? AppSpacing.xl : AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      child,
                    ],
                  ),
                ),
                if (onClose != null)
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: IconButton(
                      onPressed: onClose,
                      tooltip: 'Cerrar',
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón principal de las tarjetas de acceso: ocupa todo el ancho y, mientras
/// [loading], muestra un indicador y no se puede pulsar.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
        disabledForegroundColor: AppColors.onPrimary,
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onPrimary),
            )
          : Text(label),
    );
  }
}
