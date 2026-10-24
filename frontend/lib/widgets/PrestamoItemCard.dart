import 'package:frontend/themes/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/equipment_card.dart';
import '../models/Loan.dart';
import '../models/Session.dart';
import '../models/Item.dart';
import '../services/Cart.dart';

/// Un equipo dentro de un préstamo o del carrito: foto pequeña, nombre,
/// número de serie y cantidad. En el carrito ([editable]) se cambia la
/// cantidad o se quita el equipo.
class PrestamoItemCard extends StatefulWidget {
  final PrestamoItem prestamoItem;
  final CheckoutCart? cart;
  final bool editable;

  const PrestamoItemCard({
    super.key,
    required this.prestamoItem,
    this.cart,
    this.editable = true,
  });

  /// Equipos ya consultados, para no pedir el mismo al servidor cada vez
  /// que se abre el carrito o un préstamo.
  static final Map<int, Future<Item?>> _cache = {};

  static Future<Item?> itemById(int id) =>
      _cache.putIfAbsent(id, () => SessionManager.inventory.getItemById(id));

  /// Después de prestar o devolver cambian las unidades disponibles.
  static void clearCache() => _cache.clear();

  @override
  State<PrestamoItemCard> createState() => _PrestamoItemCardState();
}

class _PrestamoItemCardState extends State<PrestamoItemCard> {
  Item? item;

  @override
  void initState() {
    super.initState();
    PrestamoItemCard.itemById(widget.prestamoItem.itemId).then((value) {
      if (mounted) setState(() => item = value);
    });
  }

  void _setQuantity(int value) {
    widget.cart?.addItem(PrestamoItem(itemId: widget.prestamoItem.itemId, cantidad: value));
  }

  @override
  Widget build(BuildContext context) {
    final quantity = widget.prestamoItem.cantidad;
    final available = item == null ? quantity : item!.quantity - item!.quantityOnLoan;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              width: 52,
              height: 52,
              color: const Color(0xFFFFFFFF), // fotos con fondo blanco
              padding: const EdgeInsets.all(4),
              child: EquipmentImage(url: item?.imagePath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item?.nombre ?? 'Cargando…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  (item?.serialNumber ?? '').isEmpty ? 'Sin número de serie' : item!.serialNumber!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (widget.editable) ...[
            IconButton(
              onPressed: quantity > 1 ? () => _setQuantity(quantity - 1) : null,
              tooltip: 'Una menos',
              icon: const Icon(Icons.remove, size: 18),
            ),
            SizedBox(
              width: 24,
              child: Text('$quantity',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
            ),
            IconButton(
              onPressed: quantity < available ? () => _setQuantity(quantity + 1) : null,
              tooltip: 'Una más',
              icon: const Icon(Icons.add, size: 18),
            ),
            IconButton(
              onPressed: () => widget.cart?.removeItem(widget.prestamoItem.itemId),
              tooltip: 'Quitar del préstamo',
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.textMuted,
            ),
          ] else
            Text('× $quantity', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
