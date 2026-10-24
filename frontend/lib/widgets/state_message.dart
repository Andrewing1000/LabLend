import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/themes/AppTheme.dart';

/// Mensaje centrado para los estados de una página: sin resultados o error,
/// con una acción opcional (por ejemplo, "Reintentar").
class StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.color = AppColors.textSecondary,
    this.actionLabel,
    this.onAction,
  });

  /// No hay resultados para la búsqueda o los filtros.
  const StateMessage.empty({
    super.key,
    required this.title,
    this.message = 'Pruebe con otra búsqueda o quite algún filtro.',
    this.icon = Icons.search_off,
  })  : color = AppColors.textSecondary,
        actionLabel = null,
        onAction = null;

  /// No se pudieron cargar los datos. El detalle técnico no se muestra:
  /// puede revelar rutas o datos internos del servidor.
  const StateMessage.error({
    super.key,
    this.title = 'No se pudieron cargar los datos',
    this.message = 'Revise su conexión e intente de nuevo.',
    this.onAction,
  })  : icon = Icons.cloud_off_outlined,
        color = AppColors.error,
        actionLabel = 'Reintentar';

  /// Lista vacía. Los servicios devuelven una lista vacía cuando falla la
  /// conexión, así que sin conexión se avisa eso en lugar de "sin resultados".
  static Widget emptyOrOffline({
    required String title,
    required VoidCallback onRetry,
    IconData icon = Icons.search_off,
  }) {
    if (!SessionManager().isOnline) {
      return StateMessage.error(
        title: 'Sin conexión con el servidor',
        onAction: onRetry,
      );
    }
    return StateMessage.empty(title: title, icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: AppColors.textMuted),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Indicador de carga centrado.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(semanticsLabel: 'Cargando'),
    );
  }
}
