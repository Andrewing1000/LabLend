import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';

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
  void dispose() {
    currentController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (currentController.text.isEmpty || passwordController.text.isEmpty) {
      SessionManager().errorNotification(
          error: 'Escriba la contraseña actual y la nueva');
      return;
    }
    if (passwordController.text != confirmController.text) {
      SessionManager().errorNotification(error: 'Las contraseñas no coinciden');
      return;
    }
    setState(() => saving = true);
    final changed = await SessionManager()
        .changeOwnPassword(currentController.text, passwordController.text);
    if (!mounted) return;
    setState(() => saving = false);
    if (changed) widget.onDone();
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
            Text(
              widget.forced ? 'Su contraseña venció' : 'Cambiar contraseña',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (widget.forced) ...[
              const SizedBox(height: 12),
              const Text(
                'Las contraseñas vencen a los 90 días. Elija una nueva para '
                'seguir usando el sistema.',
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            PasswordField(
              controller: currentController,
              hintText: 'Contraseña actual',
              labelText: 'Contraseña actual',
              width: 300,
            ),
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
              hintText: 'Repita la contraseña nueva',
              labelText: 'Repita la contraseña nueva',
              width: 300,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: saving
                      ? null
                      : (widget.forced ? widget.onLogout : widget.onDone),
                  child: Text(widget.forced ? 'Cerrar sesión' : 'Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: saving ? null : _save,
                  child: const Text('Guardar contraseña'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
