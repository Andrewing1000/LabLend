import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/main_frame.dart';
import 'package:frontend/screens/main_frame_vertical.dart';
import 'models/Loan.dart';
import 'models/item.dart';
import 'models/User.dart';
import 'screens/home_screen.dart';

Future<void> main() async {

  runApp(MyApp());
  var manager = SessionManager();
  Session session = await manager.login("admin@example.com", "#123#AndresHinojosa#123");

  Brand dummyBrand = Brand(
    id: 1,
    marca: 'Example Brand',
  );

  // Create some dummy Categories
  List<Category> dummyCategories = [
    Category(id: 1, nombre: 'Category A', description: 'Description for Category A'),
    Category(id: 2, nombre: 'Category B', description: 'Description for Category B'),
  ];

  // Create a dummy Item
  // Item dummyItem = Item(
  //   id: 1,
  //   nombre: 'El cojudo',
  //   description: 'This is an example item for testing purposes',
  //   link: 'http://example.com/example-item',
  //   serialNumber: 'SN1234567890',
  //   quantity: 50,
  //   marca: dummyBrand,
  //   categories: dummyCategories,
  // );

  var dummyItem = await SessionManager.inventory.getItemById(1);

  DateTime p =  DateTime.now().add(Duration(days: 3));
   Loan loan = Loan(id: 1, usuario: session.user.email, fechaPrestamo: DateTime.now(),
       fechaDevolucion: p,
       devuelto: false,
       items: [PrestamoItem(item: dummyItem, cantidad: 1)] );

  loan.create();


  //User user = AssistUser(email: "pedro@pana.com", name: "Pedrolas", isActive: true);
  //user.deactivate();
  // User newUser = User.clone(user);
  // newUser.name = "NoPedrolas";

  // user.update(newUser: newUser);
  //user.create(password: "#123#AndresHinojosa#123");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        body: VerticalMainFrame(),
      ),
    );
  }
}
