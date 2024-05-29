import 'package:flutter/material.dart';
import 'Session.dart';
import 'User.dart';
import 'item.dart';


class Loan with ChangeNotifier {
  int id;
  String usuario;
  DateTime fechaPrestamo;
  DateTime fechaDevolucion;
  bool devuelto;
  List<PrestamoItem> items;

  Loan({
    required this.id,
    required this.usuario,
    required this.fechaPrestamo,
    required this.fechaDevolucion,
    required this.devuelto,
    required this.items,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      usuario: json['usuario'],
      fechaPrestamo: DateTime.parse(json['fecha_prestamo']),
      fechaDevolucion: DateTime.parse(json['fecha_devolucion']),
      devuelto: json['devuelto'],
      items: (json['items'] as List).map((i) => PrestamoItem.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario': usuario,
      'fecha_prestamo': fechaPrestamo.toIso8601String(),
      'fecha_devolucion': fechaDevolucion.toIso8601String(),
      'devuelto': devuelto,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  void create() {
    SessionManager.loanService.createLoan(this);
  }

  void update(Loan newPrestamo) {
    SessionManager.loanService.updateLoan(this, newPrestamo);
  }

  void updatePrestamo(Loan newPrestamo) {
    id = newPrestamo.id;
    usuario = newPrestamo.usuario;
    fechaPrestamo = newPrestamo.fechaPrestamo;
    fechaDevolucion = newPrestamo.fechaDevolucion;
    devuelto = newPrestamo.devuelto;
    items = newPrestamo.items;
    notifyListeners();
  }
}

class PrestamoItem {
  final Item item;
  final int cantidad;

  PrestamoItem({required this.item, required this.cantidad});

  factory PrestamoItem.fromJson(Map<String, dynamic> json) {
    return PrestamoItem(
      item: Item.fromJson(json['item']),
      cantidad: json['cantidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item.id,
      'cantidad': cantidad,
    };
  }
}
