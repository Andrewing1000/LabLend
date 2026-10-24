import 'package:frontend/themes/AppTheme.dart';
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
            return Center(
              child: Text(
                "El carrito está vacío",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.background,
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
                    color: AppColors.textPrimary.withAlpha(30),
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
                              Navigator.pop(context);
                            },
                            shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(200),
                            ),
                            backgroundColor: AppColors.primary,
                            icon: Icon(Icons.check, size: 20, color: AppColors.textPrimary,),
                            label: Text("Prestar", style: TextStyle(
                              color: AppColors.textPrimary,
                            ),)
                        ),

                        FloatingActionButton.extended(
                            onPressed: (){
                              cart.clearCart();
                              Navigator.pop(context);
                            },
                            shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(200),
                            ),
                            backgroundColor: AppColors.textPrimary,
                            icon: Icon(Icons.clear, size: 20, color: AppColors.background),
                            label: Text("Cancelar", style: TextStyle(
                              color: AppColors.background,
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
