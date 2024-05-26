import 'package:flutter/material.dart';
import 'package:frontend/widgets/boton_agregar.dart';
import 'package:frontend/models/inventory.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: BotonAgregarTestScreen(),
    ),
  ));
}

class BotonAgregarTestScreen extends StatelessWidget {
  final Inventory inventory = Inventory();

  void _createNewItem() {
    inventory.createItem();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BotonAgregar(
        onPressed: _createNewItem,
      ),
    );
  }
}
