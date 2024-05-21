import 'package:flutter/material.dart';
import '/widgets/boton_cambio.dart'; // Asegúrate de importar correctamente el widget

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: BotonCambioTest(),
    ),
  ));
}

// Clase principal que contiene la lógica y los widgets para la prueba de BotonCambio
class BotonCambioTest extends StatefulWidget {
  @override
  _BotonCambioTestState createState() => _BotonCambioTestState();
}

class _BotonCambioTestState extends State<BotonCambioTest> {
  int _seleccionadoIndex = -1; // -1 indica que ningún botón está seleccionado

  // Lista de textos para los botones
  final List<String> textosBotones = [
    "All",
    "Prueba",
    "Prueba2",

  ];

  // Método que se llama cuando un botón se selecciona
  void _onBotonPressed(int index) {
    setState(() {
      _seleccionadoIndex = index; // Actualiza el índice del botón seleccionado
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(textosBotones.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10), // Espaciado vertical entre botones
            child: BotonCambio(
              texto: textosBotones[index], // Texto único para cada botón
              colorNormal: Colors.grey, // Color del botón cuando no está seleccionado
              colorSeleccionado: Colors.green, // Color del botón cuando está seleccionado
              borde: false, // Determina si el botón tiene borde o no
              seleccionado: _seleccionadoIndex == index, // Determina si el botón está seleccionado
              onPressed: () {
                // Acción cuando el botón es presionado
                print("Botón ${textosBotones[index]} presionado");
              },
              onSelected: () => _onBotonPressed(index), // Acción cuando el botón es seleccionado
            ),
          );
        }),
      ),
    );
  }
}
