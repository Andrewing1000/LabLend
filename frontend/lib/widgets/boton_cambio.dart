import 'package:flutter/material.dart';

class BotonCambio extends StatefulWidget {
  final String texto; // Texto que se muestra en el botón
  final Color colorNormal; // Color del botón cuando no está seleccionado
  final Color colorSeleccionado; // Color del botón cuando está seleccionado
  final bool borde; // Determina si el botón tiene borde o no
  final VoidCallback onPressed; // Función que se llama al presionar el botón
  final bool seleccionado; // Indica si el botón está seleccionado
  final VoidCallback onSelected; // Función que se llama al seleccionar el botón

  const BotonCambio({
    Key? key,
    required this.texto,
    required this.colorNormal,
    required this.colorSeleccionado,
    required this.borde,
    required this.onPressed,
    required this.seleccionado,
    required this.onSelected,
  }) : super(key: key);

  @override
  _BotonCambioState createState() => _BotonCambioState();
}

class _BotonCambioState extends State<BotonCambio> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        widget.onPressed();
        widget.onSelected();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
            widget.seleccionado ? widget.colorSeleccionado : widget.colorNormal),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: widget.borde
                  ? (widget.seleccionado ? Colors.white : Colors.grey)
                  : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
      ),
      child: Text(
        widget.texto,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
