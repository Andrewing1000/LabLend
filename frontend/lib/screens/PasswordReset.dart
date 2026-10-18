import 'package:flutter/material.dart';

/// Pantalla de "Recuperar contraseña" (D24): la contraseña no se recupera
/// desde aquí, porque ninguna se envía por correo. La persona pide un
/// enlace de restablecimiento al administrador de seguridad.
class RecuperarContrasenaScreen extends StatelessWidget {
  const RecuperarContrasenaScreen({super.key});

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
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Recuperar contraseña',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Si olvidó su contraseña o su cuenta se bloqueó tras tres '
              'intentos fallidos, pida un '
              'enlace de restablecimiento al administrador de seguridad. '
              'Con el enlace podrá elegir una contraseña nueva. Vence en 24 '
              'horas y sirve una sola vez.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
