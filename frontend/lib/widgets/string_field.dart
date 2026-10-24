import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de texto con validación de obligatorio. Toma colores y bordes del
/// tema (InputDecorationTheme).
class StringField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final double width;
  final bool enabled;
  final bool required;
  final bool digitsOnly;
  final bool autofocus;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  const StringField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.width,
    this.enabled = true,
    this.required = true,
    this.digitsOnly = false,
    this.autofocus = false,
    this.prefixIcon,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
  });

  @override
  State<StringField> createState() => _StringFieldState();
}

class _StringFieldState extends State<StringField> {
  String? _errorMessage;

  void _validate() {
    if (!widget.required) return;
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
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        autofillHints: widget.autofillHints,
        inputFormatters: [
          if (widget.digitsOnly) FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          errorText: _errorMessage,
          prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
        ),
        onChanged: (_) => _validate(),
      ),
    );
  }
}
