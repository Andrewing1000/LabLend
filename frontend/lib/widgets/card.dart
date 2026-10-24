import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/models/Permissions.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/widgets/equipment_card.dart';
import 'package:provider/provider.dart';
import '../models/Item.dart';

/// Tarjeta de un equipo en la página Equipos: foto, nombre, categoría y
/// disponibilidad. Quien gestiona el inventario tiene editar y eliminar en
/// el menú de la tarjeta.
class CustomCard extends StatefulWidget {
  /// Ancho máximo de una tarjeta en la grilla y su proporción.
  static double width = 240;
  static double height = width + 78;

  final Function? onTap;
  final Function? onEdit;
  final Function? onDelete;
  final Item item;

  const CustomCard({super.key, required this.item, this.onTap, this.onEdit, this.onDelete});

  @override
  State<CustomCard> createState() => CustomCardState();
}

class CustomCardState extends State<CustomCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final canManage = SessionManager().session.user.can(AppPermission.gestionarInventario);
    final hasMenu = canManage && (widget.onEdit != null || widget.onDelete != null);

    return ChangeNotifierProvider.value(
      value: widget.item,
      child: Consumer<Item>(
        builder: (context, item, child) {
          final availability = Availability.of(item);
          final category =
              item.categories.isNotEmpty ? item.categories.first.nombre : item.marca.marca;

          return Semantics(
            button: true,
            label: '${item.nombre}, $category, ${availability.label}',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: GestureDetector(
                onTap: () => widget.onTap?.call(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF), // fotos con fondo blanco
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isHovered ? AppColors.textMuted : AppColors.border,
                              ),
                            ),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: EquipmentImage(url: item.imagePath, fit: BoxFit.contain),
                          ),
                          if (hasMenu)
                            Positioned(
                              top: AppSpacing.xs,
                              right: AppSpacing.xs,
                              child: _CardMenu(
                                onEdit: widget.onEdit == null ? null : () => widget.onEdit!(),
                                onDelete: widget.onDelete == null ? null : () => widget.onDelete!(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      item.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: availability.color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: AppSpacing.xs + 2),
                        Text(
                          availability.label,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
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

/// Menú "⋯" de la tarjeta con editar y eliminar.
class _CardMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CardMenu({this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opciones del equipo',
      icon: const Icon(Icons.more_horiz, size: 20, color: Color(0xFF555555)),
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem(value: 'edit', child: Text('Editar')),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
      ],
    );
  }
}
