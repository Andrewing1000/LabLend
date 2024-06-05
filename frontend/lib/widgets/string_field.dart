import 'package:flutter/material.dart';

class StringField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final double width;
  final bool enabled;
  final bool required;

  const StringField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.width,
    this.enabled = true,
    this.required= true,// Valor por defecto de true
  });

  @override
  _StringFieldState createState() => _StringFieldState();
}

class _StringFieldState extends State<StringField> {
  String? _errorMessage;

  void _validate() {
    if(!widget.required) return;
    setState(() {
      if (widget.controller.text.isEmpty) {
        _errorMessage = 'Este campo es obligatorio';
      } else {
        _errorMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextField(
        controller: widget.controller,
        enabled: widget.enabled, // Controla si el campo está habilitado o no
        style: const TextStyle(color: Colors.white), // Estilo del texto
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[900], // Color de fondo del campo de texto
          hintText: widget.hintText,
          hintStyle: const TextStyle(
              color: Colors.white54), // Estilo del texto de sugerencia
          errorText: _errorMessage,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                30.0), // Define el radio de las esquinas del campo de texto
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (text) {
          _validate();
        },
      ),
    );
  }
}

