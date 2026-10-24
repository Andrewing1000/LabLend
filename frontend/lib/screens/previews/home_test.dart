import 'package:flutter/material.dart';
import 'package:frontend/models/Item.dart';
import 'package:frontend/screens/HomePage.dart';
import 'package:frontend/screens/PageContainer.dart';
import 'package:frontend/services/Cart.dart';
import 'package:frontend/services/PageManager.dart';
import 'package:frontend/services/SelectedItemContext.dart';
import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/app_nav.dart';

/// Vista previa del inicio con equipos de ejemplo, sin backend:
/// flutter run -d chrome -t lib/screens/previews/home_test.dart
void main() {
  final optica = Category(id: 1, nombre: 'Óptica');
  final electronica = Category(id: 2, nombre: 'Electrónica');
  final medicion = Category(id: 3, nombre: 'Medición');
  final quimica = Category(id: 4, nombre: 'Química');
  final marca = Brand(id: 1, marca: 'Marca');

  Item item(int id, String nombre, String imagen, Category categoria, int cantidad, int prestados) {
    return Item(
      id: id,
      nombre: nombre,
      quantity: cantidad,
      quantityOnLoan: prestados,
      marca: marca,
      categories: [categoria],
      imagePath: 'assets/assets/images/$imagen',
    );
  }

  final items = [
    item(1, 'Microscopio', 'microscopio.jpg', optica, 6, 1),
    item(2, 'Centrífuga', 'centrifuga.jpg', quimica, 2, 1),
    item(3, 'Balanza analítica', 'balanza_analitica.jpg', medicion, 4, 0),
    item(4, 'Protoboard', 'protoboard.jpg', electronica, 3, 3),
    item(5, 'Espectrofotómetro', 'espectro.jpg', medicion, 2, 0),
    item(6, 'Generador de funciones', 'generador_de_funciones.jpg', electronica, 5, 2),
    item(7, 'Motor paso a paso', 'motor_paso_a_paso.jpg', electronica, 8, 1),
    item(8, 'Pinza de laboratorio', 'pinza_de_laboratorio.jpg', quimica, 10, 0),
  ];

  final home = HomePage(
    selectedItem: SelectedItemContext(),
    sections: HomeSections(
      loader: () async => (items, [optica, electronica, medicion, quimica]),
    ),
  );
  final manager = PageManager(defaultPage: home);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: PageContainer(
        manager: manager,
        navItems: [
          AppNavItem(label: 'Inicio', icon: Icons.home_outlined, selectedIcon: Icons.home, page: home),
        ],
        cart: CheckoutCart(),
        onLogin: () {},
        onLogout: () {},
        onCartLookup: () {},
      ),
    ),
  ));
}
