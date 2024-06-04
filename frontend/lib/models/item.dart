import 'package:flutter/foundation.dart';
import 'package:frontend/models/Session.dart';

class Brand extends ChangeNotifier {
  int id;
  String marca;

  Brand({required this.id, required this.marca});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      marca: json['marca'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marca': marca,
    };
  }
}

class Category extends ChangeNotifier {
  int id;
  String nombre;
  String? description;

  Category({required this.id, required this.nombre, this.description});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nombre: json['nombre'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'description': description,
    };
  }
}

class Item extends ChangeNotifier {
  int id;
  String nombre;
  String? description;
  String? link;
  String? serialNumber;
  int quantity;
  int quantityOnLoan;
  Brand marca;
  String? imagePath;
  List<Category> categories;

  Item({
    required this.id,
    required this.nombre,
    this.description,
    this.link,
    this.serialNumber,
    required this.quantity,
    required this.quantityOnLoan,
    required this.marca,
    required this.categories,
    this.imagePath,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      nombre: json['nombre'],
      description: json['description'],
      link: json['link'],
      serialNumber: json['serial_number'],
      quantityOnLoan: json['quantity_on_loan'],
      quantity: json['quantity'],
      marca: Brand.fromJson(json['marca']),
      categories: (json['categories'] as List)
          .map((i) => Category.fromJson(i))
          .toList(),
      imagePath: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'description': description,
      'link': link,
      'serial_number': serialNumber,
      'quantity': quantity,
      'quantity_on_loan' : quantityOnLoan,
      'marca': marca.toJson(),
      'categories': categories.map((c) => c.toJson()).toList(),
    };
  }

  Future<void> create() async {
    await SessionManager.inventory.createItem(this);
  }

  Future<void> update(Item newItem) async {
    await SessionManager.inventory.updateItem(this, newItem);
  }

  void updateItem(Item newItem) {
    id = newItem.id;
    nombre = newItem.nombre;
    description = newItem.description;
    link = newItem.link;
    serialNumber = newItem.serialNumber;
    quantity = newItem.quantity;
    marca = newItem.marca;
    categories = newItem.categories;
    imagePath = newItem.imagePath;
    notifyListeners();
  }
}
