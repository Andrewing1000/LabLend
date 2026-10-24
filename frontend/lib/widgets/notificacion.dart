import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/notificationCard.dart';

/// Pregunta de confirmación antes de una acción (por ejemplo, eliminar).
/// Se muestra centrada sobre un fondo oscuro; tocar fuera, la X o
/// "Cancelar" equivale a no confirmar.
class ConfirmationWidget extends NotificationWidget {
  final String buttonText;
  final Completer<bool> completer;

  ConfirmationWidget({
    super.key,
    required super.message,
    required this.buttonText,
  }) : completer = Completer<bool>();

  Future<bool> confirm() => completer.future;

  void _answer(bool value) {
    if (!completer.isCompleted) completer.complete(value);
  }

  /// Las confirmaciones de borrar o desactivar se pintan en rojo.
  bool get _destructive {
    final text = '${message.toLowerCase()} ${buttonText.toLowerCase()}';
    return ['elimin', 'borr', 'desactiv', 'revoc', 'quitar'].any(text.contains);
  }

  @override
  Widget build(BuildContext context) {
    final destructive = _destructive;
    final accent = destructive ? AppColors.error : AppColors.primary;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _answer(false),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.55)),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.94, end: 1),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Material(
                  color: AppColors.surfaceHigh,
                  elevation: 24,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg + 4),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Icon(
                                destructive ? Icons.delete_outline : Icons.help_outline,
                                color: accent,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => _answer(false),
                              tooltip: 'Cerrar',
                              icon: const Icon(Icons.close, size: 20),
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            message,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            OutlinedButton(
                              onPressed: () => _answer(false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => _answer(true),
                              style: FilledButton.styleFrom(backgroundColor: accent),
                              child: Text(buttonText),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
