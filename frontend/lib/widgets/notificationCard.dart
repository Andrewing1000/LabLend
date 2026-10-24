import 'package:flutter/material.dart';
import 'package:frontend/services/ContextMessageService.dart';
import 'package:frontend/themes/AppTheme.dart';

/// Aviso flotante abajo de la pantalla. Es neutro: el tipo (información,
/// éxito, advertencia o error) se nota solo por un punto de color.
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

  static Color colorOf(NotificationKind kind) => switch (kind) {
        NotificationKind.info => AppColors.textSecondary,
        NotificationKind.success => AppColors.success,
        NotificationKind.warning => AppColors.warning,
        NotificationKind.error => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    // En pantallas angostas queda por encima del menú inferior.
    final bottom = AppBreakpoints.isWide(context) ? AppSpacing.xl : 100.0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, bottom),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Semantics(
              liveRegion: true,
              child: Material(
                color: AppColors.surfaceHighest,
                elevation: 6,
                shadowColor: Colors.black,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.xs, AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: colorOf(kind), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      ),
                      if (onClose != null)
                        IconButton(
                          onPressed: onClose,
                          tooltip: 'Cerrar aviso',
                          icon: const Icon(Icons.close, size: 16),
                          color: AppColors.textMuted,
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
