import 'package:frontend/themes/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/fechas.dart';
import 'package:provider/provider.dart';
import '../models/Loan.dart';

/// Fila de un préstamo en la lista: quién lo pidió, fechas, cantidad de
/// equipos y estado (en curso, vencido o devuelto).
class LoanCard extends StatefulWidget {
  final Loan loan;
  final VoidCallback onTap;

  const LoanCard({super.key, required this.loan, required this.onTap});

  /// Anchos de las columnas, compartidos con el encabezado de la lista.
  static const int userFlex = 5;
  static const int datesFlex = 4;
  static const double statusWidth = 130;

  @override
  State<LoanCard> createState() => _LoanCardState();
}

class _LoanCardState extends State<LoanCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.loan,
      child: Consumer<Loan>(
        builder: (context, loan, child) {
          final status = LoanStatus.of(loan);
          final units = loan.items.fold<int>(0, (sum, i) => sum + i.cantidad);
          final compact = AppBreakpoints.isCompact(context);

          final who = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loan.usuario,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                'Préstamo #${loan.id} · $units ${units == 1 ? 'equipo' : 'equipos'}',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          );
          final dates = Text(
            '${fechaCorta(loan.fechaPrestamo)}  →  ${fechaCorta(loan.fechaDevolucion)}',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          );
          final badge = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(status.label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          );

          return Semantics(
            button: true,
            label: 'Préstamo ${loan.id} de ${loan.usuario}, ${status.label}',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: isHovered ? AppColors.surfaceHigh : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            who,
                            const SizedBox(height: AppSpacing.sm),
                            Row(children: [Expanded(child: dates), badge]),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(flex: LoanCard.userFlex, child: who),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(flex: LoanCard.datesFlex, child: dates),
                            SizedBox(width: LoanCard.statusWidth, child: badge),
                            Icon(Icons.chevron_right,
                                size: 18,
                                color: isHovered ? AppColors.textSecondary : AppColors.border),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
