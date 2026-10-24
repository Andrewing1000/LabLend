import 'package:frontend/themes/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/services/fechas.dart';
import 'package:provider/provider.dart';
import '../services/Cart.dart';
import 'PrestamoItemCard.dart';

/// "Mi préstamo" (hoja inferior): los equipos elegidos, la fecha de
/// devolución y el botón para solicitar el préstamo.
class CheckoutCartList extends StatefulWidget {
  final CheckoutCart cart;

  const CheckoutCartList({super.key, required this.cart});

  @override
  State<CheckoutCartList> createState() => _CheckoutCartListState();
}

class _CheckoutCartListState extends State<CheckoutCartList> {
  /// Por defecto, una semana; se puede elegir otra fecha.
  DateTime returnDate = DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 7));
  bool saving = false;

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: returnDate,
      firstDate: today.add(const Duration(days: 1)),
      lastDate: today.add(const Duration(days: 90)),
      helpText: 'Devolver hasta',
      cancelText: 'Cancelar',
      confirmText: 'Elegir',
    );
    if (picked != null) setState(() => returnDate = picked);
  }

  Future<void> _confirm(CheckoutCart cart) async {
    setState(() => saving = true);
    final ok = await cart.confirmLoan(SessionManager().session.user, DateTime.now(), returnDate);
    if (!mounted) return;
    setState(() => saving = false);
    // Solo se cierra si el servidor registró el préstamo; si no, el aviso
    // explica por qué y los equipos siguen en el carrito.
    if (ok) {
      PrestamoItemCard.clearCache();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.cart,
      child: Consumer<CheckoutCart>(
        builder: (context, cart, child) {
          final units = cart.items.fold<int>(0, (sum, i) => sum + i.cantidad);

          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Mi préstamo',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        ),
                        if (cart.items.isNotEmpty)
                          Text('$units ${units == 1 ? 'equipo' : 'equipos'}',
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (cart.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                        child: Text(
                          'Todavía no eligió equipos. Ábralos desde Equipos y use '
                          '"Agregar al préstamo".',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary),
                        ),
                      )
                    else ...[
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final entry in cart.items)
                              PrestamoItemCard(key: ValueKey(entry.itemId), prestamoItem: entry, cart: cart),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Devolver hasta',
                                    style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                const SizedBox(height: 2),
                                Text(fechaCorta(returnDate),
                                    style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: saving ? null : _pickDate,
                            child: const Text('Cambiar fecha'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          TextButton(
                            onPressed: saving ? null : cart.clearCart,
                            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                            child: const Text('Vaciar'),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: saving ? null : () => _confirm(cart),
                            style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
                            child: saving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: AppColors.onPrimary),
                                  )
                                : const Text('Solicitar préstamo'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
