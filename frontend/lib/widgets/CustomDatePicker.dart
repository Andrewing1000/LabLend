import 'package:flutter/material.dart';
import 'package:frontend/themes/AppTheme.dart';

/// Calendario en un diálogo para elegir una fecha o quitarla. La fecha se
/// entrega al aplicar; cancelar no cambia nada.
class CustomDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime?> onDateChanged;

  /// Título del diálogo (p. ej. el nombre del filtro).
  final String title;

  const CustomDatePicker({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
    this.title = 'Elija una fecha',
  });

  @override
  State<CustomDatePicker> createState() => CustomDatePickerDialogState();
}

class CustomDatePickerDialogState extends State<CustomDatePicker> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = _inRange(widget.initialDate);
  }

  DateTime? _inRange(DateTime? date) {
    if (date == null) return null;
    if (date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate)) return null;
    return date;
  }

  /// "Hoy" dentro del rango: el calendario abre en ese mes.
  DateTime get _today {
    final now = DateTime.now();
    if (now.isBefore(widget.firstDate)) return widget.firstDate;
    if (now.isAfter(widget.lastDate)) return widget.lastDate;
    return now;
  }

  void _close() {
    // Cerrar solo si el diálogo está en una ruta (en la vista previa es la
    // pantalla misma).
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }

  static String _format(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      selectedDate == null
                          ? 'Sin fecha elegida'
                          : _format(selectedDate!),
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              CalendarDatePicker(
                // Nueva clave al cambiar la fecha: así "Quitar fecha" también
                // limpia la marca del calendario.
                key: ValueKey(selectedDate),
                initialDate: selectedDate,
                currentDate: _today,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                onDateChanged: (date) => setState(() {
                  // Tocar otra vez la misma fecha la quita.
                  selectedDate = selectedDate == date ? null : date;
                }),
              ),
              Row(
                children: [
                  if (selectedDate != null)
                    TextButton(
                      onPressed: () => setState(() => selectedDate = null),
                      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                      child: const Text('Quitar fecha'),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: _close,
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  FilledButton(
                    onPressed: () {
                      widget.onDateChanged(selectedDate);
                      _close();
                    },
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
