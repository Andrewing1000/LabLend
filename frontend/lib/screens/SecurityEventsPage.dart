import 'package:flutter/material.dart';
import 'package:frontend/models/SecurityEvent.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';

/// Bitácora de seguridad (D28), solo para el administrador de seguridad.
/// El buscador filtra por código de usuario (quien actuó o la cuenta
/// afectada) y el filtro, por tipo de evento.
class SecurityEventsPage extends BrowsablePage {
  final EventTypeFilter typeFilter = EventTypeFilter();

  SecurityEventsPage({super.key}) {
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
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white)),
          );
        }
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return const Center(
            child: Text('No se encontraron eventos',
                style: TextStyle(color: Colors.white)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: events.length,
          separatorBuilder: (_, __) =>
              const Divider(color: Colors.white24, height: 1),
          itemBuilder: (context, index) =>
              SecurityEventTile(event: events[index]),
        );
      },
    );
  }

  @override
  void onDispose() {}

  @override
  void onSet() {}
}

class SecurityEventTile extends StatelessWidget {
  final SecurityEvent event;

  const SecurityEventTile({super.key, required this.event});

  static const Set<String> _alertTypes = {
    'inicio_sesion_fallido',
    'inicio_sesion_limitado',
    'acceso_denegado',
  };

  String _two(int n) => n.toString().padLeft(2, '0');

  String get _date {
    final t = event.timestamp;
    return '${_two(t.day)}/${_two(t.month)}/${t.year} '
        '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';
  }

  @override
  Widget build(BuildContext context) {
    final alert = _alertTypes.contains(event.eventType);
    final who = [
      if (event.actor.isNotEmpty) 'Por: ${event.actor}',
      if (event.target.isNotEmpty) 'Cuenta: ${event.target}',
      if (event.ip != null) 'IP: ${event.ip}',
    ].join(' · ');
    final detail = event.detailText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(alert ? Icons.warning_amber : Icons.info_outline,
              color: alert ? Colors.orange : Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_date,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                if (who.isNotEmpty)
                  Text(who,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                if (detail.isNotEmpty)
                  Text(detail,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
        ],
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
