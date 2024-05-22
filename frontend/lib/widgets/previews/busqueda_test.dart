import 'package:flutter/material.dart';
import 'package:frontend/widgets/barra_busqueda.dart';

void main() {
  return runApp(MaterialApp(
      home: Scaffold(
          body: Container(
            height: double.infinity,
              width: double.infinity,
              color: const Color.fromARGB(255, 110, 0, 0),
              child: BarraBusqueda(controller: TextEditingController(), onSearch: (var a) {})))));
}
