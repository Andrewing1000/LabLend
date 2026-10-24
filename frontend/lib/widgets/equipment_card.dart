import 'package:flutter/material.dart';
import 'package:frontend/models/Item.dart';
import 'package:frontend/themes/AppTheme.dart';

/// Disponibilidad de un equipo según las unidades que quedan sin prestar.
enum Availability {
  available('Disponible'),
  low('Pocas unidades'),
  onLoan('Prestado');

  final String label;
  const Availability(this.label);

  /// Color del modo actual (noche o día).
  Color get color => switch (this) {
        available => AppColors.success,
        low => AppColors.warning,
        onLoan => AppColors.textMuted,
      };

  static Availability of(Item item) {
    final free = item.quantity - item.quantityOnLoan;
    if (free <= 0) return Availability.onLoan;
    if (free <= 2) return Availability.low;
    return Availability.available;
  }
}

/// Imagen de un equipo, con la imagen de reserva si no tiene o no carga.
class EquipmentImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;

  const EquipmentImage({super.key, required this.url, this.fit = BoxFit.cover});

  static const String placeholder = 'assets/images/place_holder.png';

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(placeholder, fit: fit);
    if (url == null || url!.isEmpty) return fallback;
    return Image.network(
      url!,
      fit: fit,
      errorBuilder: (context, error, stack) => fallback,
    );
  }
}

/// Tarjeta de equipo de las filas del inicio: foto grande, nombre y estado.
class EquipmentCard extends StatefulWidget {
  final Item item;
  final double width;
  final VoidCallback onTap;

  const EquipmentCard({
    super.key,
    required this.item,
    required this.onTap,
    this.width = 240,
  });

  @override
  State<EquipmentCard> createState() => _EquipmentCardState();
}

class _EquipmentCardState extends State<EquipmentCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final availability = Availability.of(item);
    final category = item.categories.isNotEmpty ? item.categories.first.nombre : item.marca.marca;

    return SizedBox(
      width: widget.width,
      child: Semantics(
        button: true,
        label: '${item.nombre}, $category, ${availability.label}',
        excludeSemantics: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => hovered = true),
          onExit: (_) => setState(() => hovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Container(
                      color: const Color(0xFFFFFFFF), // las fotos de equipos tienen fondo blanco
                      child: AnimatedScale(
                        scale: hovered ? 1.05 : 1,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: EquipmentImage(url: item.imagePath),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  item.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '$category · '),
                    TextSpan(
                      text: availability.label,
                      style: TextStyle(color: availability.color, fontWeight: FontWeight.w600),
                    ),
                  ]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mosaico de una categoría con foto y su nombre en una píldora.
class CategoryTile extends StatefulWidget {
  final String name;
  final String? imageUrl;
  final double width;
  final double height;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onTap,
    this.width = 300,
    this.height = 260,
  });

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ver equipos de ${widget.name}',
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg + 4),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: const Color(0xFFFFFFFF),
                    child: AnimatedScale(
                      scale: hovered ? 1.05 : 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: EquipmentImage(url: widget.imageUrl),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                    right: AppSpacing.lg,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
