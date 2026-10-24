import 'package:frontend/themes/AppTheme.dart';
import 'package:flutter/material.dart';
import '../screens/PageBase.dart';

/// Filtro de una página de búsqueda, en la barra superior junto al
/// buscador: un botón con el nombre del filtro (y el valor elegido) que
/// abre la lista de opciones.
class DropDownFilter extends StatefulWidget {
  final Filter filter;

  const DropDownFilter({super.key, required this.filter});

  @override
  State<DropDownFilter> createState() => DropDownFilterState();
}

class DropDownFilterState extends State<DropDownFilter> {
  final MenuController _menu = MenuController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant DropDownFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      _loaded = false;
      _load();
    }
  }

  /// Carga (o vuelve a cargar) las opciones. Antes se pedían en cada
  /// reconstrucción de la barra; ahora al mostrarse y al abrir la lista,
  /// para que las opciones del servidor (p. ej. los roles) estén al día.
  Future<void> _load() async {
    final filter = widget.filter;
    try {
      await filter.getItems();
    } catch (_) {
      // Sin opciones: el filtro no se muestra.
    }
    if (mounted && filter == widget.filter) setState(() => _loaded = true);
  }

  void _toggle(dynamic item) {
    final filter = widget.filter;
    filter.isSelected(item) ? filter.deselect(item) : filter.select(item);
  }

  @override
  Widget build(BuildContext context) {
    final filter = widget.filter;
    return ListenableBuilder(
      listenable: filter,
      builder: (context, _) {
        final items = filter.items;
        // Sin opciones (o sin permiso para verlas) el filtro no aparece.
        if (_loaded && items.isEmpty) return const SizedBox.shrink();

        final selected = filter.getSelected();
        final value = selected.isEmpty
            ? null
            : selected.map((item) => filter.getRepresentation(item)).join(', ');

        return MenuAnchor(
          controller: _menu,
          onOpen: _load,
          alignmentOffset: const Offset(0, AppSpacing.xs),
          style: filterMenuStyle(),
          menuChildren: [
            for (final item in items)
              MenuItemButton(
                closeOnActivate: !filter.multiple,
                onPressed: () => _toggle(item),
                leadingIcon: SizedBox(
                  width: 18,
                  child: filter.isSelected(item)
                      ? Icon(Icons.check, size: 18, color: AppColors.primary)
                      : null,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    filter.getRepresentation(item),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight:
                          filter.isSelected(item) ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            if (selected.isNotEmpty) ...[
              const Divider(),
              MenuItemButton(
                onPressed: filter.clearSelected,
                leadingIcon: const SizedBox(width: 18),
                child: Text('Quitar filtro',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ),
            ],
          ],
          builder: (context, controller, _) => FilterPill(
            label: filter.attributeName,
            value: value,
            open: controller.isOpen,
            onTap: () => controller.isOpen ? controller.close() : controller.open(),
            onClear: selected.isEmpty ? null : filter.clearSelected,
          ),
        );
      },
    );
  }
}

/// Estilo de las listas que abren los filtros.
MenuStyle filterMenuStyle() => MenuStyle(
      backgroundColor: WidgetStatePropertyAll(AppColors.surfaceHigh),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      elevation: const WidgetStatePropertyAll(2),
      side: WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: AppSpacing.xs)),
      maximumSize: const WidgetStatePropertyAll(Size(380, 440)),
    );

/// Botón de un filtro: contorno fino, el nombre del filtro y, si hay uno
/// elegido, su valor y una cruz para quitarlo.
class FilterPill extends StatefulWidget {
  final String label;

  /// Valor elegido para mostrar, o null si el filtro no está aplicado.
  final String? value;
  final IconData? leadingIcon;
  final bool open;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const FilterPill({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
    this.leadingIcon,
    this.open = false,
  });

  @override
  State<FilterPill> createState() => _FilterPillState();
}

class _FilterPillState extends State<FilterPill> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.value != null;
    final highlighted = active || widget.open || hovered;

    return Semantics(
      button: true,
      label: active ? '${widget.label}: ${widget.value}' : widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: widget.onClear != null ? AppSpacing.xs : AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: hovered || widget.open ? AppColors.surfaceHigh : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: highlighted ? AppColors.textMuted : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.leadingIcon != null) ...[
                  Icon(widget.leadingIcon, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: AppSpacing.sm),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: widget.label,
                        style: TextStyle(
                          color: active ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                      if (active)
                        TextSpan(
                          text: ': ${widget.value}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                if (widget.onClear != null)
                  IconButton(
                    onPressed: widget.onClear,
                    tooltip: 'Quitar filtro',
                    icon: const Icon(Icons.close, size: 16),
                    color: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                    padding: EdgeInsets.zero,
                  )
                else
                  Icon(
                    widget.open ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
