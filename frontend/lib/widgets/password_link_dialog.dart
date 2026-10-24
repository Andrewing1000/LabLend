import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/PasswordLink.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/themes/AppTheme.dart';

/// Muestra una sola vez un enlace de activación (D26) o de restablecimiento
/// (D24): el servidor guarda solo su hash y no lo puede volver a mostrar.
Future<void> showPasswordLinkDialog(
    BuildContext context, PasswordLink link) async {
  final what = link.isActivation
      ? 'Con él, ${link.username} elegirá su contraseña y activará su cuenta.'
      : 'Con él, ${link.username} elegirá una contraseña nueva.';

  void copy() {
    Clipboard.setData(ClipboardData(text: link.url));
    SessionManager().notification(notification: 'Enlace copiado');
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(link.isActivation ? 'Enlace de activación' : 'Enlace de restablecimiento'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Entregue este enlace a ${link.username}. $what',
                style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      link.url,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                  IconButton(
                    onPressed: copy,
                    tooltip: 'Copiar enlace',
                    icon: const Icon(Icons.copy, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Vence en 24 horas, sirve una sola vez y no se volverá a mostrar: '
              'cópielo antes de cerrar.',
              style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: copy,
          child: const Text('Copiar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Listo'),
        ),
      ],
    ),
  );
}
