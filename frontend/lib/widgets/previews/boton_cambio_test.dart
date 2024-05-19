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

class BotonCambioTest extends StatefulWidget {
  @override
  _BotonCambioTestState createState() => _BotonCambioTestState();
}

class _BotonCambioTestState extends State<BotonCambioTest> {
  int _seleccionadoIndex = -1; // -1 indica que ningún botón está seleccionado

  // Lista de textos para los botones
  final List<String> textosBotones = [
    "Play",
    "Pause",
    "Stop",
    "Rewind",
    "Forward"
  ];

  // Método que se llama cuando un botón se selecciona
  void _onBotonPressed(int index) {
    setState(() {
      _seleccionadoIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(textosBotones.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: BotonCambio(
              texto: textosBotones[index], // Texto único para cada botón
              colorNormal: Colors.grey,
              colorSeleccionado: Colors.green,
              borde: true,
              seleccionado: _seleccionadoIndex == index,
              onPressed: () {
                print("Botón ${textosBotones[index]} presionado");
              },
              onSelected: () => _onBotonPressed(index),
            ),
          );
        }),
      ),
    );
  }
}
