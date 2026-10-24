import 'package:frontend/themes/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/services/Cart.dart';
import 'package:provider/provider.dart';
import '../models/Loan.dart';
import 'PrestamoItemCard.dart';

class Reviewloan extends StatelessWidget {
  final Loan loan;

  const Reviewloan({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: loan),
      ],
      child: Consumer<Loan>(
        builder: (context, loan, child) {
          if(loan.items.isEmpty){
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
                    itemCount: loan.items.length,
                    itemBuilder: (context, index) {
                      final prestamoItem = loan.items[index];
                      return PrestamoItemCard(
                        prestamoItem: prestamoItem,
                        cart: CheckoutCart(),
                        editable: false,
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
                        if(!loan.devuelto) FloatingActionButton.extended(
                            onPressed: () async {
                                await SessionManager.loanService.updateDevuelto(loan, true);
                                await SessionManager.inventory.getItems();
                                Navigator.pop(context);
                            },
                            shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(200),
                            ),
                            backgroundColor: AppColors.primary,
                            icon: Icon(Icons.check, size: 20, color: AppColors.textPrimary,),
                            label: Text("Devolver", style: TextStyle(
                              color: AppColors.textPrimary,
                              ),
                            )
                        ),

                        if(loan.devuelto)
                          Center(
                            child: Row(
                              children: [
                                Text("Devuelto",
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                ),
                              ],
                            )
                          )
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
