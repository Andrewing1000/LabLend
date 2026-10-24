import 'package:flutter/material.dart';

/// Campo de contraseña con botón para mostrarla u ocultarla. Toma colores y
/// bordes del tema (InputDecorationTheme).
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final double width;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  /// Error a mostrar desde fuera (por ejemplo, "Las contraseñas no coinciden").
  final String? errorText;

  const PasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.width,
    this.labelText = 'Contraseña',
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
    this.errorText,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isObscured = true;
  String? _errorMessage;

  void _validate() {
    setState(() {
      _errorMessage = widget.controller.text.isEmpty ? 'Este campo es obligatorio' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextField(
        controller: widget.controller,
        obscureText: _isObscured,
        autofocus: widget.autofocus,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        autofillHints: widget.autofillHints,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText.isEmpty ? null : widget.hintText,
          errorText: widget.errorText ?? _errorMessage,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            tooltip: _isObscured ? 'Mostrar contraseña' : 'Ocultar contraseña',
            icon: Icon(_isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            onPressed: () => setState(() => _isObscured = !_isObscured),
          ),
        ),
        onChanged: (_) => _validate(),
      ),
    );
  }
}
