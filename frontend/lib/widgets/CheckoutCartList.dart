import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/Cart.dart';
import 'PrestamoItemCard.dart';

class CheckoutCartList extends StatelessWidget {
  final CheckoutCart cart;

  const CheckoutCartList({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: cart),
      ],
      child: Consumer<CheckoutCart>(
        builder: (context, cart, child) {
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black,
            ),
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final prestamoItem = cart.items[index];
                return PrestamoItemCard(
                  prestamoItem: prestamoItem,
                  cart: cart,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
