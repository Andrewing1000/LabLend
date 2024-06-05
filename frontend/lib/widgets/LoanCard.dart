import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Loan.dart';

class LoanCard extends StatefulWidget {
  final Loan loan;
  final VoidCallback onTap;

  LoanCard({required this.loan, required this.onTap});

  @override
  _LoanCardState createState() => _LoanCardState();
}

class _LoanCardState extends State<LoanCard> {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: _onEnter,
        onExit: _onExit,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: widget.loan),
          ],
          child: Consumer<Loan>(
            builder: (context, loan, child) {
              return Card(
                color: isHovered ? Colors.grey[850] : Colors.black,
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 3,
                        fit: FlexFit.tight,
                        child: Text(
                          loan.usuario,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 16),
                      Flexible(
                        flex: 3,
                        fit: FlexFit.tight,
                        child: Text(
                          '${loan.fechaPrestamo}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 16),
                      Flexible(
                        flex: 3,
                        fit: FlexFit.tight,
                        child: Text(
                          '${loan.fechaDevolucion}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 16),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Icon(
                          loan.devuelto ? Icons.check_circle : Icons.cancel,
                          color: loan.devuelto ? Colors.orange : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
