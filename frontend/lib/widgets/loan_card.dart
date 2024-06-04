import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Loan.dart';
import '../models/item.dart';
import '../models/Session.dart';

class LoanCard extends StatefulWidget {
  static double width = 300;
  static double height = 300;

  final Loan loan;
  final Item item;
  final Function()? onReturn;

  LoanCard({super.key, required this.loan, required this.item, this.onReturn});

  @override
  State<LoanCard> createState() {
    return LoanCardState();
  }
}

class LoanCardState extends State<LoanCard> {
  bool isHovered = false;

  void _onEnter(PointerEvent event) {
    setState(() {
      isHovered = true;
    });
  }

  void _onExit(PointerEvent event) {
    setState(() {
      isHovered = false;
    });
  }

  Future<void> _returnLoan() async {
    widget.loan.devuelto = true;
    await SessionManager.loanService.updateLoan(widget.loan, widget.loan);
    if (widget.onReturn != null) {
      widget.onReturn!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.loan),
        ChangeNotifierProvider.value(value: widget.item),
      ],
      child: Consumer2<Loan, Item>(builder: (context, loan, item, child) {
        var prestamoItem = loan.items.isNotEmpty
            ? loan.items.firstWhere((i) => i.itemId == item.id,
                orElse: () => PrestamoItem(itemId: item.id, cantidad: 0))
            : PrestamoItem(itemId: item.id, cantidad: 0);

        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: LoanCard.width,
            height: LoanCard.height,
            child: MouseRegion(
              onEnter: _onEnter,
              onExit: _onExit,
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  color: isHovered
                      ? Colors.white.withAlpha(20)
                      : const Color.fromRGBO(21, 21, 21, 1.0),
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          height: LoanCard.height * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              item.imagePath != null
                                  ? item.imagePath!
                                  : "assets/images/place_holder.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.nombre,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: "/assets/fonts/Metropolis-Black.ttf",
                          ),
                        ),
                        Text(
                          "Cantidad: ${prestamoItem.cantidad}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: loan.devuelto ? null : _returnLoan,
                          child: Text(loan.devuelto ? 'Devuelto' : 'Devolver'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
