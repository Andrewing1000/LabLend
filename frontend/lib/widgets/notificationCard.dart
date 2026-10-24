import 'package:flutter/material.dart';
import 'package:frontend/services/ContextMessageService.dart';
import 'package:frontend/themes/AppTheme.dart';

/// Aviso flotante abajo de la pantalla. Su ícono y color dicen si es
/// información, éxito, advertencia o error.
class NotificationWidget extends StatelessWidget {
  final String message;
  final NotificationKind kind;
  final VoidCallback? onClose;

  const NotificationWidget({
    super.key,
    required this.message,
    this.kind = NotificationKind.info,
    this.onClose,
  });

  static (IconData, Color) styleOf(NotificationKind kind) => switch (kind) {
        NotificationKind.info => (Icons.info_outline, AppColors.primary),
        NotificationKind.success => (Icons.check_circle_outline, AppColors.success),
        NotificationKind.warning => (Icons.warning_amber_rounded, AppColors.warning),
        NotificationKind.error => (Icons.error_outline, AppColors.error),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, color) = styleOf(kind);
    // En pantallas angostas queda por encima del menú inferior.
    final bottom = AppBreakpoints.isWide(context) ? AppSpacing.xl : 100.0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, bottom),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: child),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Semantics(
              liveRegion: true,
              child: Material(
                color: AppColors.surfaceHighest,
                elevation: 12,
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md + 2),
                  side: BorderSide(color: color.withOpacity(0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.xs, AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 22),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (onClose != null)
                        IconButton(
                          onPressed: onClose,
                          tooltip: 'Cerrar aviso',
                          icon: const Icon(Icons.close, size: 18),
                          color: AppColors.textSecondary,
                        )
                      else
                        const SizedBox(width: AppSpacing.md),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
