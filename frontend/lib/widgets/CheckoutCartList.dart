import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
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
          if(cart.items.isEmpty){
            return const Center(
              child: Text(
                "El carrito está vacío",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black,
            ),
            child: Column(
              children: [
                Flexible(
                  flex: 6,
                  fit: FlexFit.tight,
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
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(5),
                    color: Colors.white.withAlpha(30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        FloatingActionButton.extended(
                            onPressed: (){
                              cart.confirmLoan(
                                  SessionManager().session.user,
                                  DateTime.now(),
                                  DateTime.now().add(const Duration(days: 1)));
                            },
                            shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(200),
                            ),
                            backgroundColor: Colors.indigo,
                            icon: const Icon(Icons.check, size: 20, color: Colors.white,),
                            label: const Text("Prestar", style: TextStyle(
                              color: Colors.white,
                            ),)
                        ),

                        FloatingActionButton.extended(
                            onPressed: (){
                              cart.clearCart();
                            },
                            shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(200),
                            ),
                            backgroundColor: Colors.white,
                            icon: const Icon(Icons.clear, size: 20, color: Colors.black),
                            label: const Text("Cancelar", style: TextStyle(
                              color: Colors.black,
                              )
                            )
                        ),

                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
