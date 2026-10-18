import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/PasswordLink.dart';
import 'package:frontend/models/Session.dart';

/// Muestra una sola vez un enlace de activación (D26) o de restablecimiento
/// (D24): el servidor guarda solo su hash y no lo puede volver a mostrar.
Future<void> showPasswordLinkDialog(
    BuildContext context, PasswordLink link) async {
  final what = link.isActivation
      ? 'Con él, ${link.username} elegirá su contraseña y activará su cuenta.'
      : 'Con él, ${link.username} elegirá una contraseña nueva.';
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(link.isActivation
          ? 'Enlace de activación'
          : 'Enlace de restablecimiento'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Entregue este enlace a ${link.username}. $what Vence en 24 '
              'horas, sirve una sola vez y no se volverá a mostrar.'),
          const SizedBox(height: 12),
          SelectableText(link.url),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: link.url));
            SessionManager().notification(notification: 'Enlace copiado');
          },
          child: const Text('Copiar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}
