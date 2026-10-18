import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';

import '../widgets/password_creation_field.dart';
import '../widgets/password_field.dart';

/// Página que abre un enlace de restablecimiento (D24): muestra el código
/// de usuario de la cuenta y deja elegir una contraseña nueva. No requiere
/// sesión: quien tiene el enlace todavía no puede iniciar sesión.
class PasswordLinkScreen extends StatefulWidget {
  final String token;
  final Function() onDone;

  const PasswordLinkScreen(
      {super.key, required this.token, required this.onDone});

  @override
  State<PasswordLinkScreen> createState() => _PasswordLinkScreenState();
}

class _PasswordLinkScreenState extends State<PasswordLinkScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  bool loading = true;
  bool saving = false;
  String? username;

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final result =
        await SessionManager.userManager.checkPasswordLink(widget.token);
    if (!mounted) return;
    setState(() {
      username = result;
      loading = false;
    });
  }

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
    final saved = await SessionManager.userManager
        .usePasswordLink(widget.token, passwordController.text);
    if (!mounted) return;
    setState(() => saving = false);
    if (saved) {
      SessionManager().notification(
          notification: 'Contraseña guardada. Ya puede iniciar sesión.');
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Elegir una contraseña nueva',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (loading)
              const CircularProgressIndicator()
            else if (username == null) ...[
              const Text(
                'El enlace no es válido o venció. Pida uno nuevo al '
                'administrador de seguridad.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.onDone,
                child: const Text('Ir al inicio de sesión'),
              ),
            ] else ...[
              Text('Código de usuario: $username'),
              const SizedBox(height: 20),
              PasswordCreationField(
                controller: passwordController,
                hintText: 'Contraseña nueva',
                labelText: 'Contraseña nueva',
                width: 300,
              ),
              const SizedBox(height: 20),
              PasswordField(
                controller: confirmController,
                hintText: 'Repita la contraseña',
                labelText: 'Repita la contraseña',
                width: 300,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saving ? null : _save,
                child: const Text('Guardar contraseña'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
