/// Evento de la bitácora de seguridad (D28). Solo lectura: el servidor no
/// permite modificar ni eliminar eventos.
class SecurityEvent {
  /// Tipos de evento del servidor y su nombre para mostrar.
  static const Map<String, String> types = {
    'inicio_sesion': 'Inicio de sesión',
    'inicio_sesion_fallido': 'Inicio de sesión fallido',
    'inicio_sesion_limitado': 'Inicio de sesión rechazado por el límite de intentos',
    'cierre_sesion': 'Cierre de sesión',
    'cuenta_creada': 'Cuenta creada',
    'cuenta_modificada': 'Cuenta modificada por el administrador',
    'perfil_modificado': 'Perfil propio modificado',
    'contrasena_propia_cambiada': 'Contraseña propia cambiada',
    'acceso_denegado': 'Acción rechazada',
  };

  final int id;
  final DateTime timestamp;
  final String eventType;
  final String label;
  final String actor;
  final String target;
  final String? ip;
  final Map<String, dynamic> detail;

  SecurityEvent({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.label,
    required this.actor,
    required this.target,
    required this.ip,
    required this.detail,
  });

  factory SecurityEvent.fromJson(Map<String, dynamic> data) {
    return SecurityEvent(
      id: data['id'],
      timestamp: DateTime.parse(data['timestamp']).toLocal(),
      eventType: data['event_type'],
      label: data['event_label'] ?? data['event_type'],
      actor: data['actor_username'] ?? '',
      target: data['target_username'] ?? '',
      ip: data['ip'],
      detail: Map<String, dynamic>.from(data['detail'] ?? {}),
    );
  }

  /// Detalle en una línea legible, p. ej. "is_active: true → false".
  String get detailText {
    final parts = <String>[];
    detail.forEach((key, value) {
      if (key == 'cambios' && value is Map) {
        value.forEach((field, change) {
          if (change is List && change.length == 2) {
            parts.add('$field: ${change[0]} → ${change[1]}');
          }
        });
      } else if (key == 'contrasena_cambiada') {
        if (value == true) parts.add('contraseña cambiada');
      } else if (value != null && value.toString().isNotEmpty) {
        parts.add('$key: $value');
      }
    });
    return parts.join(' · ');
  }
}
