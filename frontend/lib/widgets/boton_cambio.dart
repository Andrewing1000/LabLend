import 'package:flutter/material.dart';

// Definición del widget personalizado BotonCambio que extiende StatefulWidget
class BotonCambio extends StatefulWidget {
  final String texto; // Texto que se muestra en el botón
  final Color colorNormal; // Color del botón cuando no está seleccionado
  final Color colorSeleccionado; // Color del botón cuando está seleccionado
  final bool borde; // Indica si el botón tiene un borde visible
  final VoidCallback onPressed; // Función que se llama al presionar el botón
  final bool seleccionado; // Indica si el botón está actualmente seleccionado
  final VoidCallback onSelected; // Función que se llama cuando el botón se selecciona

  // Constructor del widget, que inicializa todos los parámetros requeridos
  const BotonCambio({
    super.key,
    required this.texto,
    required this.colorNormal,
    required this.colorSeleccionado,
    required this.borde,
    required this.onPressed,
    required this.seleccionado,
    required this.onSelected,
  });

  @override
  _BotonCambioState createState() => _BotonCambioState();
}

// Estado asociado al widget BotonCambio
class _BotonCambioState extends State<BotonCambio> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // Acción que se ejecuta al presionar el botón
      onPressed: () {
        widget.onPressed(); // Llama a la función onPressed pasada como parámetro
        widget.onSelected(); // Llama a la función onSelected pasada como parámetro
      },
      // Estilo del botón
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          widget.seleccionado ? widget.colorSeleccionado : widget.colorNormal, // Cambia el color del botón según el estado de seleccionado
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Define el radio de las esquinas del botón
            side: BorderSide(
              color: widget.borde
                  ? (widget.seleccionado ? Colors.white : Colors.grey) // Cambia el color del borde según el estado de seleccionado
                  : Colors.transparent, // Sin borde si la propiedad borde es falsa
              width: 2.0, // Ancho del borde
            ),
          ),
        ),
      ),
      // Contenido del botón: texto que se muestra
      child: Text(
        widget.texto,
        style: const TextStyle(
          color: Colors.white, // Color del texto
          fontSize: 16, // Tamaño del texto
        ),
      ),
    );
  }
}
