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
                    color: Colors.white.withAlpha(30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if(!loan.devuelto) FloatingActionButton.extended(
                            onPressed: (){
                              SessionManager.loanService.updateDevuelto(loan, true);
                            },
                            shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(200),
                            ),
                            backgroundColor: Colors.indigo,
                            icon: const Icon(Icons.check, size: 20, color: Colors.white,),
                            label: const Text("Devolver", style: TextStyle(
                              color: Colors.white,
                              ),
                            )
                        ),

                        if(loan.devuelto)
                          const Center(
                            child: Row(
                              children: [
                                Text("Devuelto",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.orange,
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
