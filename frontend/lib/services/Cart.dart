import '../models/Item.dart';
import '../models/Loan.dart';
import 'package:flutter/foundation.dart';
import '../models/Session.dart';
import '../models/User.dart';

class CheckoutCart with ChangeNotifier {
  final List<PrestamoItem> _items = [];
  List<PrestamoItem> get items => List.unmodifiable(_items);

  void addItem(PrestamoItem item) {
    var existingItem = _items.firstWhere((i) => i.itemId == item.itemId, orElse: () => PrestamoItem(itemId: item.itemId, cantidad: 0));

    if (existingItem.cantidad == 0) {
      item.cart = this;
      _items.add(item);
    } else {
      existingItem.cantidad = item.cantidad;
      existingItem.cart = this; // Ensure cart is assigned
    }
    refresh();
  }

  void refresh() {
    _items.removeWhere((item) => item.cantidad == 0);
    notifyListeners();
  }

  void removeItem(int itemId) {
    _items.removeWhere((item) => item.itemId == itemId);
    for(PrestamoItem item in _items){
      print(item.itemId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<void> confirmLoan(User usuario, DateTime fechaPrestamo, DateTime fechaDevolucion) async {
    if (_items.isEmpty) {
      throw Exception('Cannot confirm loan with an empty cart.');
    }

    Loan newLoan = Loan(
      id: 0,  // Assuming id will be set by the backend
      usuario: usuario.email,
      fechaPrestamo: fechaPrestamo,
      fechaDevolucion: fechaDevolucion,
      devuelto: false,
      items: _items,
    );

    for(PrestamoItem pItem in _items){
      Item? item = await SessionManager.inventory.getItemById(pItem.itemId);
      if(item == null) continue;
      item.onLoan += pItem.cantidad;
    }

    try {
      await SessionManager.loanService.createLoan(newLoan);
      clearCart();
    } catch (e) {
      throw Exception('Failed to confirm loan: $e');
    }
  }
}
