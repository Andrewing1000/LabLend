import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/themes/AppTheme.dart';

import '../widgets/auth_card.dart';
import '../widgets/password_creation_field.dart';
import '../widgets/password_field.dart';

/// Cambio de la contraseña propia (D14): pide la actual y la nueva dos
/// veces. Con la contraseña vencida (D21) es obligatorio: no se puede
/// cerrar, solo cambiarla o cerrar la sesión, y el servidor rechaza
/// cualquier otra acción mientras tanto.
class ChangePasswordScreen extends StatefulWidget {
  final bool forced;
  final Function() onDone;
  final Function() onLogout;

  const ChangePasswordScreen({
    super.key,
    required this.forced,
    required this.onDone,
    required this.onLogout,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController currentController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    // Para avisar en vivo si la confirmación no coincide.
    passwordController.addListener(_refresh);
    confirmController.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    currentController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  String? get _mismatch => confirmController.text.isNotEmpty &&
          confirmController.text != passwordController.text
      ? 'Las contraseñas no coinciden'
      : null;

  Future<void> _save() async {
    if (currentController.text.isEmpty || passwordController.text.isEmpty) {
      SessionManager().errorNotification(error: 'Escriba la contraseña actual y la nueva');
      return;
    }
    if (passwordController.text != confirmController.text) {
      SessionManager().errorNotification(error: 'Las contraseñas no coinciden');
      return;
    }
    setState(() => saving = true);
    final changed =
        await SessionManager().changeOwnPassword(currentController.text, passwordController.text);
    if (!mounted) return;
    setState(() => saving = false);
    if (changed) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      icon: widget.forced ? Icons.lock_clock_outlined : Icons.key_outlined,
      accent: widget.forced ? AppColors.warning : AppColors.primary,
      title: widget.forced ? 'Su contraseña venció' : 'Cambiar contraseña',
      subtitle: widget.forced
          ? 'Las contraseñas vencen a los 90 días. Elija una nueva para seguir '
              'usando el sistema.'
          : 'Por seguridad, primero confirme su contraseña actual.',
      // Si está vencida no se puede cerrar: hay que cambiarla o salir.
      onClose: widget.forced || saving ? null : widget.onDone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PasswordField(
            controller: currentController,
            hintText: '',
            labelText: 'Contraseña actual',
            width: double.infinity,
            autofocus: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.password],
          ),
          const SizedBox(height: AppSpacing.lg),
          PasswordCreationField(
            controller: passwordController,
            hintText: '',
            labelText: 'Contraseña nueva',
            width: double.infinity,
          ),
          const SizedBox(height: AppSpacing.lg),
          PasswordField(
            controller: confirmController,
            hintText: '',
            labelText: 'Repita la contraseña nueva',
            width: double.infinity,
            errorText: _mismatch,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Tampoco puede ser una contraseña común ni una de las últimas 5 que usó.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthPrimaryButton(
            label: 'Guardar contraseña',
            loading: saving,
            onPressed: _save,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: saving ? null : (widget.forced ? widget.onLogout : widget.onDone),
            child: Text(widget.forced ? 'Cerrar sesión' : 'Cancelar'),
          ),
        ],
      ),
    );
  }
}
