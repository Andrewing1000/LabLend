import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/themes/AppTheme.dart';

import '../widgets/auth_card.dart';
import '../widgets/password_field.dart';
import '../widgets/string_field.dart';

class LoginScreen extends StatefulWidget {
  final Future<void> Function(String username, String password) onSubmit;
  final Function() onPasswordReset;
  final VoidCallback? onClose;

  const LoginScreen({
    super.key,
    required this.onSubmit,
    required this.onPasswordReset,
    this.onClose,
  });

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (loading) return;
    if (userController.text.isEmpty || passwordController.text.isEmpty) {
      SessionManager().errorNotification(
          error: 'Escriba su código de usuario y su contraseña');
      return;
    }
    setState(() => loading = true);
    try {
      await widget.onSubmit(userController.text, passwordController.text);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      icon: Icons.lock_outline,
      title: 'Iniciar sesión',
      subtitle: 'Ingrese con su código de usuario del laboratorio.',
      onClose: widget.onClose,
      // Sin AutofillGroup: en Flutter web junta los campos en un formulario
      // oculto y, al copiar o cambiar de campo, el foco real queda en el
      // primero y lo que se escribe no llega al campo que se ve activo.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StringField(
            labelText: 'Código de usuario',
            controller: userController,
            hintText: 'usr.jperez',
            width: double.infinity,
            autofocus: true,
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
          ),
          const SizedBox(height: AppSpacing.lg),
          PasswordField(
            controller: passwordController,
            hintText: '',
            width: double.infinity,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _submit(),
            autofillHints: const [AutofillHints.password],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: loading ? null : widget.onPasswordReset,
              child: const Text('¿Olvidó su contraseña?'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AuthPrimaryButton(
            label: 'Iniciar sesión',
            loading: loading,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
              SizedBox(width: AppSpacing.xs + 2),
              Flexible(
                child: Text(
                  'Tras 3 intentos fallidos la cuenta se bloquea.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
