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
  int quantity_on_loan;
  Brand marca;
  List<Category> categories;

  Item({
    required this.id,
    required this.nombre,
    this.description,
    this.link,
    this.serialNumber,
    required this.quantity,
    required this.quantity_on_loan,
    required this.marca,
    required this.categories,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      nombre: json['nombre'],
      description: json['description'],
      link: json['link'],
      serialNumber: json['serial_number'],
      quantity: json['quantity'],
      quantity_on_loan: json['quantity_on_loan'],
      marca: Brand.fromJson(json['marca']),
      categories: (json['categories'] as List).map((i) => Category.fromJson(i)).toList(),
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
      'quantity_on_loan' : quantity_on_loan,
      'marca': marca.toJson(),
      'categories': categories.map((c) => c.toJson()).toList(),
    };
  }

  void create(){
    SessionManager.inventory.createItem(this);
  }

  void update(Item newItem){
    SessionManager.inventory.updateItem(this, newItem);
  }

  void updateItem(Item newItem) {

    nombre = newItem.nombre;
    description = newItem.description;
    link = newItem.link;
    serialNumber = newItem.serialNumber;
    quantity = newItem.quantity;
    marca = newItem.marca;
    categories = newItem.categories;
    notifyListeners();
  }
}




