import 'package:flutter/material.dart';
import 'package:frontend/screens/PageBase.dart';

import 'DropDownFilter.dart';

/// Filtro por fecha en la barra superior ("Desde", "Hasta"): el mismo botón
/// que los demás filtros; al tocarlo abre el calendario.
class DropdownDateFilter extends StatefulWidget {
  /// Fecha en la que abre el calendario si todavía no se eligió ninguna.
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateFilter filter;

  DropdownDateFilter({
    super.key,
    this.initialDate,
    required this.filter,
  })  : firstDate = DateTime(2024, 1, 1),
        lastDate = DateTime.now().add(const Duration(days: 1));

  @override
  DropdownDateFilterState createState() => DropdownDateFilterState();
}

class DropdownDateFilterState extends State<DropdownDateFilter> {
  bool _open = false;

  /// La fecha se lee del filtro y no de una copia propia: así el botón
  /// muestra siempre lo que de verdad filtra la página.
  DateTime? get _selectedDate {
    final selected = widget.filter.getSelected();
    return selected.isEmpty ? null : selected.first;
  }

  DateTime _clamp(DateTime date) {
    if (date.isBefore(widget.firstDate)) return widget.firstDate;
    if (date.isAfter(widget.lastDate)) return widget.lastDate;
    return date;
  }

  Future<void> _selectDate(BuildContext context) async {
    setState(() => _open = true);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _clamp(_selectedDate ?? widget.initialDate ?? DateTime.now()),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      helpText: widget.filter.attributeName,
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
    );
    if (!mounted) return;
    setState(() => _open = false);
    // Cancelar deja el filtro como estaba (antes lo borraba).
    if (picked == null || picked == _selectedDate) return;
    widget.filter.select(picked);
  }

  static String _format(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    final local = date.toLocal();
    return '${two(local.day)}/${two(local.month)}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.filter,
      builder: (context, _) {
        final date = _selectedDate;
        return FilterPill(
          label: widget.filter.attributeName,
          value: date == null ? null : _format(date),
          leadingIcon: Icons.calendar_today_outlined,
          open: _open,
          onTap: () => _selectDate(context),
          onClear: date == null ? null : widget.filter.clearSelected,
        );
      },
    );
  }
}
