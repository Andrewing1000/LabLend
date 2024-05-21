import 'package:flutter/material.dart';
import 'package:frontend/widgets/barra_busqueda.dart';

void main() {
  return runApp(MaterialApp(
      home: Scaffold(
          body: Container(
            height: double.infinity,
              width: double.infinity,
              child: BarraBusqueda(onSearch: (var a) {}),
              color: Color.fromARGB(255, 110, 0, 0)))));
}
