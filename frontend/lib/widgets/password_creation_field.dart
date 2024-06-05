import 'package:flutter/material.dart';

// Definición del widget PasswordCreationField que extiende StatefulWidget
class PasswordCreationField extends StatefulWidget {
  final TextEditingController controller; // Controlador para el campo de texto
  final String hintText; // Texto de sugerencia para el campo de texto
  final double width; // Ancho del campo de texto

  const PasswordCreationField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.width,
  });

  // Método para verificar si la contraseña es válida
  bool isValid(String password) {
    final RegExp hasUpperCase =
        RegExp(r'[A-Z]'); // Verifica si contiene mayúsculas
    final RegExp hasLowerCase =
        RegExp(r'[a-z]'); // Verifica si contiene minúsculas
    final RegExp hasDigit = RegExp(r'\d'); // Verifica si contiene dígitos
    final RegExp hasSpecialCharacter = RegExp(
        r'[!@#$%^&*(),.?":{}|<>]'); // Verifica si contiene caracteres especiales

    // Verifica los requisitos mínimos de la contraseña
    return password.length >= 8 &&
        hasUpperCase.hasMatch(password) &&
        hasLowerCase.hasMatch(password) &&
        hasDigit.hasMatch(password) &&
        hasSpecialCharacter.hasMatch(password);
  }

  // Método para evaluar la fuerza de la contraseña
  double getStrength(String password) {
    if (!isValid(password)) return 0; // Si no es válida, fuerza es 0

    double strength = 0;
    final int length = password.length;
    final RegExp hasUpperCase = RegExp(r'[A-Z]');
    final RegExp hasLowerCase = RegExp(r'[a-z]');
    final RegExp hasDigit = RegExp(r'\d');
    final RegExp hasSpecialCharacter = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    // Incremento de la fuerza basado en la longitud
    if (length >= 8) strength += 0.1;
    if (length >= 12) strength += 0.1;
    if (length >= 16) strength += 0.1;

    // Incremento de la fuerza basado en la complejidad
    if (hasUpperCase.hasMatch(password)) strength += 0.15;
    if (hasLowerCase.hasMatch(password)) strength += 0.15;
    if (hasDigit.hasMatch(password)) strength += 0.15;
    if (hasSpecialCharacter.hasMatch(password)) strength += 0.15;

    // Diversidad de caracteres
    final uniqueChars = password.split('').toSet().length;
    if (uniqueChars > 10) strength += 0.1;
    if (uniqueChars > 15) strength += 0.1;

    // Penalización por patrones repetitivos (e.g., Maria123@123)
    final RegExp repetitivePattern = RegExp(r'(.)\1\1');
    if (repetitivePattern.hasMatch(password)) strength -= 0.2;

    // Penalización por secuencias predecibles (e.g., abc, 123)
    final List<String> sequences = [
      'abcdefghijklmnopqrstuvwxyz',
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
      '0123456789'
    ];
    for (String sequence in sequences) {
      for (int i = 0; i < sequence.length - 3; i++) {
        if (password.contains(sequence.substring(i, i + 3))) {
          strength -= 0.1;
        }
      }
    }

    return strength.clamp(0, 1); // Fuerza limitada entre 0 y 1
  }

  @override
  _PasswordCreationFieldState createState() => _PasswordCreationFieldState();
}

// Estado asociado al widget PasswordCreationField
class _PasswordCreationFieldState extends State<PasswordCreationField> {
  bool _isObscured = true; // Estado para controlar si la contraseña está oculta
  double _strength = 0; // Estado para almacenar la fuerza de la contraseña
  bool _isValid = false; // Estado para almacenar la validez de la contraseña

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(
        _updatePasswordCriteria); // Agrega listener para actualizar la fuerza y validez
  }

  @override
  void dispose() {
    widget.controller
        .removeListener(_updatePasswordCriteria); // Elimina listener
    super.dispose();
  }

  // Método para alternar la visibilidad de la contraseña
  void _toggleObscured() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  // Método para actualizar la fuerza y validez de la contraseña
  void _updatePasswordCriteria() {
    setState(() {
      _strength = widget.getStrength(widget.controller.text);
      _isValid = widget.isValid(widget.controller.text);
      //print("Password: ${widget.controller.text}"); // Mostrar la contraseña en la consola
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: widget.width, // Ancho del campo de texto
          child: TextField(
            controller: widget.controller,
            obscureText: _isObscured, // Controla la visibilidad del texto
            style: const TextStyle(color: Colors.white), // Estilo del texto
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[900], // Color de fondo del campo de texto
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                  color: Colors.white54), // Estilo del texto de sugerencia
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54, // Color del icono
                ),
                onPressed:
                    _toggleObscured, // Alterna la visibilidad al presionar el icono
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    30.0), // Define el radio de las esquinas del campo de texto
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: widget.width, // Ancho de la barra de progreso
          child: LinearProgressIndicator(
            value: _strength, // Valor de la fuerza de la contraseña
            backgroundColor: Colors.red,
            valueColor: AlwaysStoppedAnimation<Color>(_strength < 0.33
                ? Colors.red
                : _strength < 0.66
                    ? Colors.yellow
                    : Colors.green),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Fuerza: ${(_strength * 100).toInt()}%",
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(
          _isValid ? "Contraseña valida" : "Contraseña Invalida",
          style: TextStyle(
            color: _isValid ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
