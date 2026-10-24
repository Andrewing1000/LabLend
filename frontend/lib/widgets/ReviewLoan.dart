import 'package:frontend/themes/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/services/fechas.dart';
import 'package:provider/provider.dart';
import '../models/Loan.dart';
import 'PrestamoItemCard.dart';

/// Detalle de un préstamo (hoja inferior): datos, equipos y, si sigue en
/// curso, el botón para marcarlo como devuelto.
class Reviewloan extends StatefulWidget {
  final Loan loan;
  const Reviewloan({super.key, required this.loan});

  @override
  State<Reviewloan> createState() => _ReviewloanState();
}

class _ReviewloanState extends State<Reviewloan> {
  bool saving = false;

  Future<void> _markReturned(Loan loan) async {
    final confirmed = await SessionManager().confirmNotification(
        message: '¿Confirmar que se devolvieron los equipos del préstamo #${loan.id}?');
    if (!confirmed) return;
    setState(() => saving = true);
    final updated = await SessionManager.loanService.updateDevuelto(loan, true);
    if (!mounted) return;
    setState(() => saving = false);
    // Solo se cierra si el servidor lo registró.
    if (updated != null) {
      PrestamoItemCard.clearCache();
      SessionManager.inventory.markStockChanged();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.loan,
      child: Consumer<Loan>(
        builder: (context, loan, child) {
          final status = LoanStatus.of(loan);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Préstamo #${loan.id}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(status.label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _Line(label: 'Usuario', value: loan.usuario),
                  _Line(label: 'Prestado el', value: fechaCorta(loan.fechaPrestamo)),
                  _Line(label: 'Devolver hasta', value: fechaCorta(loan.fechaDevolucion)),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Equipos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final entry in loan.items)
                          PrestamoItemCard(prestamoItem: entry, editable: false),
                      ],
                    ),
                  ),
                  if (!loan.devuelto) ...[
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: saving ? null : () => _markReturned(loan),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      child: saving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                            )
                          : const Text('Marcar como devuelto'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  const _Line({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
