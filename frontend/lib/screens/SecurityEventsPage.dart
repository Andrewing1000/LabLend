import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/state_message.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/SecurityEvent.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';

/// Bitácora de seguridad (D28), solo para el administrador de seguridad.
/// El buscador filtra por código de usuario (quien actuó o la cuenta
/// afectada) y el filtro, por tipo de evento.
class SecurityEventsPage extends BrowsablePage {
  final EventTypeFilter typeFilter = EventTypeFilter();

  SecurityEventsPage({super.key}) : super(searchHint: 'Buscar por código de usuario') {
    filterSet.add(typeFilter);
  }

  Future<List<SecurityEvent>> _fetchEvents(String? username) async {
    String? eventType;
    if (typeFilter.getSelected().isNotEmpty) {
      eventType = typeFilter.getSelected().first;
    }
    return await SessionManager.userManager.getSecurityEvents(
      username: username,
      eventType: eventType,
    );
  }

  @override
  Widget build(BuildContext context, SearchField searchField,
      FilterList filters, Widget? child) {
    String? username;
    if (searchField.value.isNotEmpty) {
      username = searchField.value;
    }

    return FutureBuilder<List<SecurityEvent>>(
      future: _fetchEvents(username),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState();
        }
        if (snapshot.hasError) {
          return StateMessage.error(onAction: () => searchField.value = searchField.value);
        }
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return StateMessage.emptyOrOffline(
            title: 'No se encontraron eventos',
            icon: Icons.shield_outlined,
            onRetry: () => searchField.value = searchField.value,
          );
        }
        return _EventLog(events: events);
      },
    );
  }

  @override
  void onDispose() {}

  @override
  void onSet() {}
}

/// Cuántos eventos pide la página al servidor (UserManager.getSecurityEvents).
const int _eventLimit = 200;

/// Tipos de evento que se marcan como alerta (un punto de color).
const Set<String> _alertTypes = {
  'inicio_sesion_fallido',
  'inicio_sesion_limitado',
  'acceso_denegado',
  'cuenta_bloqueada',
  'contrasena_actual_incorrecta',
};

String _two(int n) => n.toString().padLeft(2, '0');

/// Lista de eventos agrupada por día, con un resumen arriba.
class _EventLog extends StatelessWidget {
  final List<SecurityEvent> events;

  const _EventLog({required this.events});

  static String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'HOY';
    if (diff == 1) return 'AYER';
    return '${_two(day.day)}/${_two(day.month)}/${day.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Filas planas: un encabezado por día y luego sus eventos, en el orden
    // en que llegan del servidor (del más reciente al más antiguo).
    final rows = <Object>[];
    DateTime? currentDay;
    for (final event in events) {
      final t = event.timestamp;
      final day = DateTime(t.year, t.month, t.day);
      if (day != currentDay) {
        rows.add(_dayLabel(day));
        currentDay = day;
      }
      rows.add(event);
    }
    final alerts = events.where((e) => _alertTypes.contains(e.eventType)).length;
    final compact = AppBreakpoints.isCompact(context);
    final side = compact ? AppSpacing.lg : AppSpacing.xl;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(side, AppSpacing.xl, side, AppSpacing.sm),
              sliver: SliverToBoxAdapter(
                child: _EventsSummary(total: events.length, alerts: alerts),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(side, 0, side, AppSpacing.xxl),
              sliver: SliverList.builder(
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final row = rows[index];
                  return row is SecurityEvent
                      ? SecurityEventTile(event: row)
                      : _DayHeader(label: row as String);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsSummary extends StatelessWidget {
  final int total;
  final int alerts;

  const _EventsSummary({required this.total, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '$total',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: total == 1 ? '  evento' : '  eventos',
                  style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
              ]),
              style: TextStyle(color: AppColors.textPrimary),
            ),
            if (alerts > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _AlertDot(),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Text(alerts == 1 ? '1 alerta' : '$alerts alertas',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
          ],
        ),
        if (total >= _eventLimit) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Se muestran los $_eventLimit eventos más recientes. Filtre por usuario '
            'o por tipo para ver otros.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String label;

  const _DayHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.xl, 0, AppSpacing.sm),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _AlertDot extends StatelessWidget {
  const _AlertDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
    );
  }
}

/// Fila de la bitácora: hora, tipo de evento, quién actuó y sobre qué
/// cuenta, y el detalle. Las alertas llevan un punto de color.
class SecurityEventTile extends StatelessWidget {
  final SecurityEvent event;

  const SecurityEventTile({super.key, required this.event});

  String get _time {
    final t = event.timestamp;
    return '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';
  }

  @override
  Widget build(BuildContext context) {
    final alert = _alertTypes.contains(event.eventType);
    final detail = event.detailText;
    final mono = TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary);

    final who = <InlineSpan>[
      if (event.actor.isNotEmpty) TextSpan(text: event.actor, style: mono),
      if (event.actor.isNotEmpty && event.target.isNotEmpty)
        const TextSpan(text: '  →  '),
      if (event.actor.isEmpty && event.target.isNotEmpty)
        const TextSpan(text: 'Cuenta '),
      if (event.target.isNotEmpty) TextSpan(text: event.target, style: mono),
      if (event.ip != null && event.ip!.isNotEmpty)
        TextSpan(
            text: '${event.actor.isEmpty && event.target.isEmpty ? '' : '  ·  '}'
                'IP ${event.ip}'),
    ];

    return Semantics(
      label: '${alert ? 'Alerta. ' : ''}${event.label}, $_time',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 76,
              child: Text(
                _time,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            // Columna del punto: alineada aunque el evento no sea alerta.
            SizedBox(
              width: 15,
              child: alert
                  ? const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Align(alignment: Alignment.topLeft, child: _AlertDot()),
                    )
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (who.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text.rich(
                      TextSpan(children: who),
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                  if (detail.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      detail,
                      style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventTypeFilter extends SingleFilter<String> {
  EventTypeFilter() : super(attributeName: 'Tipo de evento');

  @override
  String getRepresentation(String item) {
    return SecurityEvent.types[item] ?? item;
  }

  @override
  Future<List<String>> retrieveItems() async {
    return SecurityEvent.types.keys.toList();
  }
}
