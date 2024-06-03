import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/widgets/item_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de la sesión para autenticación
  var manager = SessionManager();
  Session session = await SessionManager()
      .login("admin@example.com", "#123#AndresHinojosa#123");

  // Crear un ítem de prueba
  Brand dummyBrand = Brand(
    id: 1,
    marca: 'Example Brand',
  );

  List<Category> dummyCategories = [
    Category(
        id: 1, nombre: 'Category A', description: 'Description for Category A'),
    Category(
        id: 2, nombre: 'Category B', description: 'Description for Category B'),
  ];

  Item dummyItem = Item(
    id: 1,
    nombre: 'Example Item',
    description: 'This is an example item for testing purposes',
    link: 'http://example.com/example-item',
    serialNumber: 'SN1234567890',
    quantity: 50,
    marca: dummyBrand,
    categories: dummyCategories,
  );

  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Item Info Test'),
        backgroundColor: Colors.black,
      ),
      body: ItemInfoWidget(item: dummyItem),
    ),
  ));
}
