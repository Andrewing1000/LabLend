import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/main_frame.dart';

import 'models/Loan.dart';
import 'models/item.dart';
import 'models/User.dart';
import 'screens/home_screen.dart';

Future<void> main() async {

  runApp(MyApp());
  var manager = SessionManager();
  Session session = await manager.login("admin@example.com", "#123#AndresHinojosa#123");


  ///
  ///
  /// Cerrar sesion
  //await SessionManager().logOut();

  ///
  ///
  ///Obtener usuario por el email
  //User? user = await SessionManager.userManager.getUser("admin2@example.com");

  ///
  ///
  ///
  /// Listar usuarios
  //var list = await SessionManager.userManager.getUserList();


  ///
  ///
  ///ListarItems
  //var listItems = await SessionManager.inventory.getItems();


  ///
  ///
  /// Crear Marcas
  // Brand dummyBrand = Brand(
  //   id: 1,
  //   marca: 'Example Brand',
  // );


  ///
  ///
  /// Crear Categorias

  // List<Category> dummyCategories = [
  //   Category(id: 1, nombre: 'Category A', description: 'Description for Category A'),
  //   Category(id: 2, nombre: 'Category B', description: 'Description for Category B'),
  // ];

  ///
  ///
  ///
  /// Crear item
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
  //dummyItem.create();


  ///
  ///
  /// Obtener Item por id
  // Item? dummyItem = await SessionManager.inventory.getItemById(1);
  // print(dummyItem?.toJson().toString());


  ///
  ///
  ///
  /// Crear prestamo
  //  Loan loan = Loan(id: 1, usuario: session.user.email, fechaPrestamo: DateTime.now(),
  //      fechaDevolucion: DateTime.now().add(Duration(days:1)),
  //      devuelto: false,
  //      items: [PrestamoItem(itemId: dummyItem!.id, cantidad: 1)] );
  //
  // loan.create();


  ///
  ///
  /// Obtener prestamo usando id
  //Loan? loan = await SessionManager.loanService.getLoan(20);


  ///
  ///
  /// Devolver prestamo
  //SessionManager.loanService.updateDevuelto(loan, true);


  ///
  ///
  /// Buscar prestamos en rango de fechas y estado de devolucion
  // var listo =  await SessionManager.loanService.getLoanList(devuelto: false,
  //     endDate: DateTime.now().add(Duration(days: 1)),
  //     startDate: DateTime.now().add(Duration(days: 0)),
  //     email: "admin2");


  ///
  ///
  /// Desactivar y actualizar Usuario
  // User user = AssistUser(email: "pedro@pana.com", name: "Pedrolas", isActive: true);
  // user.deactivate();
  // User newUser = user.clone();
  // newUser.name = "NoPedrolas";
  //
  // user.update(newUser: newUser);
  // user.create(password: "#123#AndresHinojosa#123");

  ///
  ///
  /// Obtner marcas
  // List<Brand> brandList = await SessionManager.inventory.getBrands();

  ///
  ///
  /// Obtener Items con categorias
  // List<Item> list= await SessionManager.inventory.getItems(brandId: 1, categoryIds: [1]);

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        body: SessionManager.mainFrame,
      ),
    );
  }
}
