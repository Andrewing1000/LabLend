import 'package:flutter/material.dart';
import 'package:frontend/models/Loan.dart';
import 'package:frontend/themes/AppTheme.dart';

const _meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/// "24 oct 2026"
String fechaCorta(DateTime fecha) {
  final f = fecha.toLocal();
  return '${f.day} ${_meses[f.month - 1]} ${f.year}';
}

/// Estado de un préstamo para mostrar.
enum LoanStatus {
  returned('Devuelto'),
  overdue('Vencido'),
  active('En curso');

  final String label;
  const LoanStatus(this.label);

  /// Color del modo actual (noche o día).
  Color get color => switch (this) {
        returned => AppColors.textMuted,
        overdue => AppColors.warning,
        active => AppColors.success,
      };

  static LoanStatus of(Loan loan) {
    if (loan.devuelto) return returned;
    // Vencido: pasó el día de devolución y no se devolvió.
    final hoy = DateUtils.dateOnly(DateTime.now());
    if (DateUtils.dateOnly(loan.fechaDevolucion.toLocal()).isBefore(hoy)) return overdue;
    return active;
  }
}
