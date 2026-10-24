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
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Registra el préstamo con los equipos del carrito. Devuelve true si el
  /// servidor lo aceptó; solo entonces se vacía el carrito (si falla, el
  /// usuario no pierde lo que había elegido).
  Future<bool> confirmLoan(User usuario, DateTime fechaPrestamo, DateTime fechaDevolucion) async {
    if (_items.isEmpty) return false;

    final newLoan = Loan(
      id: 0, // lo asigna el servidor
      usuario: usuario.email,
      fechaPrestamo: fechaPrestamo,
      fechaDevolucion: fechaDevolucion,
      devuelto: false,
      items: List.of(_items),
    );

    final created = await SessionManager.loanService.createLoan(newLoan);
    if (created == null) return false;
    SessionManager.inventory.markStockChanged();
    clearCart();
    return true;
  }
}
