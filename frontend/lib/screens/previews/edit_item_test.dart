import 'package:flutter/material.dart';
import 'package:frontend/screens/edit_item_screen.dart';
import 'package:frontend/models/Session.dart';

import '../../models/Item.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de la sesión para autenticación
  var manager = SessionManager();
  Session session = await SessionManager()
      .login("admin@example.com", "#123#AndresHinojosa#123");

  Item dummyItem = Item(
    id: 1,
    nombre: 'El cojudo',
    description: 'This is an example item for testing purposes',
    link: 'http://example.com/example-item',
    serialNumber: 'SN1234567890',
    quantity: 50,
    marca: Brand(marca: "", id: 1),
    categories: [],
    quantityOnLoan: 0,
  );

  runApp(MaterialApp(
    home: EditItemScreen(item: dummyItem,),
  ));
}
