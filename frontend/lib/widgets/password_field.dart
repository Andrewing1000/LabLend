import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final double width;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.width,
  }) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isObscured = true; // Estado para controlar si la contraseña está oculta
  String? _errorMessage;


  void _validate() {
    setState(() {
      if (widget.controller.text.isEmpty) {
        _errorMessage = 'Este campo es obligatorio';
      } else {
        _errorMessage = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
    super.dispose();
  }

  // Método para alternar la visibilidad de la contraseña
  void _toggleObscured() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: TextField(
        controller: widget.controller,
        obscureText: _isObscured, // Controla la visibilidad del texto
        style: TextStyle(color: Colors.white), // Estilo del texto
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[900], // Color de fondo del campo de texto
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.white54), // Estilo del texto de sugerencia
          suffixIcon: IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_off : Icons.visibility,
              color: Colors.white54, // Color del icono
            ),
            onPressed: _toggleObscured, // Alterna la visibilidad al presionar el icono
          ),
          errorText: _errorMessage,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0), // Define el radio de las esquinas del campo de texto
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
