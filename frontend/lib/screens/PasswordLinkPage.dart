import 'package:flutter/material.dart';
import 'package:frontend/models/PasswordLink.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/themes/AppTheme.dart';

import '../widgets/auth_card.dart';
import '../widgets/password_creation_field.dart';
import '../widgets/password_field.dart';

/// Página que abre un enlace de activación (D26) o de restablecimiento
/// (D24): muestra el código de usuario de la cuenta y deja elegir la
/// contraseña. No requiere sesión: quien tiene el enlace todavía no puede
/// iniciar sesión.
class PasswordLinkScreen extends StatefulWidget {
  final String token;
  final Function() onDone;

  const PasswordLinkScreen({super.key, required this.token, required this.onDone});

  @override
  State<PasswordLinkScreen> createState() => _PasswordLinkScreenState();
}

class _PasswordLinkScreenState extends State<PasswordLinkScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  bool loading = true;
  bool saving = false;
  PasswordLink? link;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_refresh);
    confirmController.addListener(_refresh);
    _check();
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final result = await SessionManager.userManager.checkPasswordLink(widget.token);
    if (!mounted) return;
    setState(() {
      link = result;
      loading = false;
    });
  }

  String? get _mismatch => confirmController.text.isNotEmpty &&
          confirmController.text != passwordController.text
      ? 'Las contraseñas no coinciden'
      : null;

  Future<void> _save() async {
    if (passwordController.text.isEmpty) {
      SessionManager().errorNotification(error: 'Escriba la contraseña nueva');
      return;
    }
    if (passwordController.text != confirmController.text) {
      SessionManager().errorNotification(error: 'Las contraseñas no coinciden');
      return;
    }
    setState(() => saving = true);
    final saved =
        await SessionManager.userManager.usePasswordLink(widget.token, passwordController.text);
    if (!mounted) return;
    setState(() => saving = false);
    if (saved) {
      SessionManager().notification(
          notification: isActivation
              ? 'Cuenta activada. Ya puede iniciar sesión.'
              : 'Contraseña guardada. Ya puede iniciar sesión.');
      widget.onDone();
    }
  }

  bool get isActivation => link?.isActivation ?? false;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const AuthCard(
        icon: Icons.link,
        title: 'Revisando el enlace',
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (link == null) {
      return AuthCard(
        icon: Icons.link_off,
        accent: AppColors.error,
        title: 'El enlace no sirve',
        subtitle: 'No es válido, ya se usó o venció. Pida uno nuevo al '
            'administrador de seguridad.',
        child: AuthPrimaryButton(
          label: 'Ir al inicio de sesión',
          onPressed: widget.onDone,
        ),
      );
    }

    return AuthCard(
      icon: isActivation ? Icons.verified_user_outlined : Icons.key_outlined,
      title: isActivation ? 'Activar su cuenta' : 'Elegir una contraseña nueva',
      subtitle: isActivation
          ? 'Elija la contraseña con la que va a iniciar sesión.'
          : 'Elija una contraseña nueva para su cuenta.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.md),
                const Text('Código de usuario',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const Spacer(),
                Flexible(
                  child: Text(
                    link!.username,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
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
            labelText: 'Repita la contraseña',
            width: double.infinity,
            errorText: _mismatch,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthPrimaryButton(
            label: isActivation ? 'Activar cuenta' : 'Guardar contraseña',
            loading: saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
