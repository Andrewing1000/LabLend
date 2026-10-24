import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/models/Permissions.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Loan.dart';
import 'package:frontend/models/Item.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/services/Cart.dart';
import 'package:frontend/services/PageManager.dart';
import 'package:frontend/services/SelectedItemContext.dart';
import 'package:frontend/widgets/equipment_card.dart';
import 'package:provider/provider.dart';

/// Detalle del equipo elegido: foto, datos y, para quien registra
/// préstamos, la cantidad y el botón para agregarlo al préstamo en curso.
class ItemInfoWidget extends StatefulWidget {
  final SelectedItemContext itemContext;
  final PageManager pageManager;
  final CheckoutCart cart;

  const ItemInfoWidget({
    super.key,
    required this.itemContext,
    required this.pageManager,
    required this.cart,
  });

  @override
  State<ItemInfoWidget> createState() => _ItemInfoWidgetState();
}

class _ItemInfoWidgetState extends State<ItemInfoWidget> {
  /// Cantidad elegida para el equipo que se está viendo.
  int quantity = 1;
  int? _shownItemId;

  PrestamoItem? _inCart(Item item) {
    for (final entry in widget.cart.items) {
      if (entry.itemId == item.id) return entry;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.itemContext),
        ChangeNotifierProvider.value(value: widget.cart),
        ChangeNotifierProvider.value(value: SessionManager()),
      ],
      child: Consumer3<SelectedItemContext, CheckoutCart, SessionManager>(
        builder: (context, itemContext, cart, sessionManager, child) {
          final item = itemContext.item;
          if (item == null) return const SizedBox.shrink();

          final entry = _inCart(item);
          // Al abrir otro equipo, la cantidad vuelve a la que tiene en el
          // préstamo, o a 1.
          if (_shownItemId != item.id) {
            _shownItemId = item.id;
            quantity = entry?.cantidad ?? 1;
          }

          final available = item.quantity - item.quantityOnLoan;
          final availability = Availability.of(item);
          final canLoan = sessionManager.session.user.can(AppPermission.registrarPrestamos);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.nombre,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: itemContext.unsetItem,
                      tooltip: 'Cerrar',
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(color: availability.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      available > 0
                          ? '$available de ${item.quantity} disponibles'
                          : 'Todas las unidades están prestadas',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    color: const Color(0xFFFFFFFF), // las fotos de equipos tienen fondo blanco
                    height: 240,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: EquipmentImage(url: item.imagePath, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if ((item.description ?? '').trim().isNotEmpty) ...[
                  Text(
                    item.description!,
                    style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                _Detail(label: 'Marca', value: item.marca.marca),
                _Detail(
                  label: 'Categorías',
                  value: item.categories.isEmpty
                      ? 'Sin categoría'
                      : item.categories.map((c) => c.nombre).join(', '),
                ),
                _Detail(label: 'Número de serie', value: item.serialNumber ?? 'No registrado'),
                if (canLoan && item.id != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _LoanControls(
                    quantity: quantity,
                    available: available,
                    inCart: entry != null,
                    onChanged: (value) {
                      setState(() => quantity = value);
                      // Si ya está en el préstamo, la cantidad se actualiza ahí.
                      if (entry != null) {
                        cart.addItem(PrestamoItem(itemId: item.id!, cantidad: value));
                      }
                    },
                    onToggle: () {
                      if (entry != null) {
                        cart.removeItem(item.id!);
                      } else if (quantity <= available) {
                        cart.addItem(PrestamoItem(itemId: item.id!, cantidad: quantity));
                      } else {
                        SessionManager().warningNotification(
                            warning: 'No hay suficientes unidades disponibles');
                      }
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final String label;
  final String value;
  const _Detail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

/// Cantidad y botón para agregar el equipo al préstamo en curso (o quitarlo).
class _LoanControls extends StatelessWidget {
  final int quantity;
  final int available;
  final bool inCart;
  final ValueChanged<int> onChanged;
  final VoidCallback onToggle;

  const _LoanControls({
    required this.quantity,
    required this.available,
    required this.inCart,
    required this.onChanged,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (available <= 0 && !inCart) {
      return Text('No hay unidades para prestar en este momento.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted));
    }
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
                tooltip: 'Una menos',
                icon: const Icon(Icons.remove, size: 18),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
                ),
              ),
              IconButton(
                onPressed: quantity < available ? () => onChanged(quantity + 1) : null,
                tooltip: 'Una más',
                icon: const Icon(Icons.add, size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: inCart
              ? OutlinedButton(
                  onPressed: onToggle,
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                  child: const Text('Quitar del préstamo'),
                )
              : FilledButton(
                  onPressed: onToggle,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                  child: const Text('Agregar al préstamo'),
                ),
        ),
      ],
    );
  }
}
