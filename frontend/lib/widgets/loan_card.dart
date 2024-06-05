import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Loan.dart';
import '../models/item.dart';
import '../models/Session.dart';

class LoanCard extends StatefulWidget {
  static double width = 300;
  static double height = 150;

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

  void _showLoanDetails() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.black,
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Préstamo de ${widget.loan.usuario}',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Fecha de préstamo: ${widget.loan.fechaPrestamo}\nFecha de devolución: ${widget.loan.fechaDevolucion}',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.loan.items.length,
                  itemBuilder: (context, index) {
                    final prestamoItem = widget.loan.items[index];
                    return ListTile(
                      leading: Image.network(
                        widget.item.imagePath ??
                            'assets/images/place_holder.png',
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      ),
                      title: Text(widget.item.nombre,
                          style: TextStyle(color: Colors.white)),
                      subtitle: Text('Cantidad: ${prestamoItem.cantidad}',
                          style: TextStyle(color: Colors.white70)),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
                onTap: _showLoanDetails,
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
                        Row(
                          children: [
                            Container(
                              height: LoanCard.height * 0.8,
                              width: LoanCard.height * 0.8,
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
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nombre,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Cantidad: ${prestamoItem.cantidad}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Usuario: ${loan.usuario}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Fecha Préstamo: ${loan.fechaPrestamo}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Fecha Devolución: ${loan.fechaDevolucion}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!loan.devuelto)
                              IconButton(
                                icon: Icon(Icons.check_circle,
                                    color: Colors.green),
                                onPressed: _returnLoan,
                              ),
                            if (loan.devuelto)
                              Icon(Icons.check_circle, color: Colors.green),
                          ],
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
