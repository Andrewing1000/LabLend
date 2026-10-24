import 'dart:async';

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

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _answer(false),
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              builder: (context, t, child) => Opacity(opacity: t, child: child),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Material(
                  color: AppColors.surfaceHigh,
                  elevation: 12,
                  shadowColor: Colors.black,
                  borderRadius: BorderRadius.circular(AppRadius.md + 2),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          liveRegion: true,
                          child: Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: Text(
                              message,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.55,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _answer(false),
                              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            // Borrar o desactivar: el texto del botón va en
                            // el tono de error, sin fondo de color.
                            destructive
                                ? TextButton(
                                    onPressed: () => _answer(true),
                                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                    child: Text(buttonText),
                                  )
                                : FilledButton(
                                    onPressed: () => _answer(true),
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
