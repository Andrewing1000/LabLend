import 'package:flutter/material.dart';
import 'package:frontend/themes/AppTheme.dart';

import '../widgets/auth_card.dart';

/// Pantalla de "Recuperar contraseña" (D24): la contraseña no se recupera
/// desde aquí, porque ninguna se envía por correo. La persona pide un
/// enlace de restablecimiento al administrador de seguridad.
class RecuperarContrasenaScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  const RecuperarContrasenaScreen({super.key, this.onBack, this.onClose});

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      icon: Icons.key_outlined,
      title: 'Recuperar contraseña',
      subtitle: 'Por seguridad, las contraseñas no se envían por correo. '
          'Si la olvidó o su cuenta se bloqueó tras tres intentos fallidos:',
      onClose: onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Step(
            number: 1,
            text: 'Pida un enlace de restablecimiento al administrador de seguridad.',
          ),
          const _Step(
            number: 2,
            text: 'Abra el enlace: vence en 24 horas y sirve una sola vez.',
          ),
          const _Step(
            number: 3,
            text: 'Elija una contraseña nueva y vuelva a iniciar sesión.',
          ),
          if (onBack != null) ...[
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Volver a iniciar sesión'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String text;

  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.surfaceHighest,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, height: 1.45, color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
