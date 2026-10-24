import 'package:flutter/foundation.dart';
import 'package:frontend/widgets/notificacion.dart';
import 'package:frontend/widgets/notificationCard.dart';

/// Tipo de aviso: define su ícono y su color.
enum NotificationKind { info, success, warning, error }

class ContextMessageService extends ChangeNotifier {
  NotificationWidget? _notification;
  bool displaying;

  /// Cada aviso nuevo invalida el temporizador del anterior, para que un
  /// aviso no se esconda antes de tiempo si llegan dos seguidos.
  int _serial = 0;

  ContextMessageService({this.displaying = false});

  NotificationWidget? get notification => _notification;

  void _show() {
    displaying = true;
    notifyListeners();
  }

  void _hide() {
    displaying = false;
    notifyListeners();
  }

  /// Cierra el aviso actual (botón X).
  void dismiss() {
    if (_notification is ConfirmationWidget) {
      focusLost();
      return;
    }
    _serial++;
    _hide();
  }

  void focusLost() {
    if (_notification is ConfirmationWidget) {
      final confirmationWidget = (_notification as ConfirmationWidget);
      if (!confirmationWidget.completer.isCompleted) {
        confirmationWidget.completer.complete(false);
      }
      displaying = false;
    }
    notifyListeners();
  }

  void notify({
    required String message,
    NotificationKind kind = NotificationKind.info,
    Duration? duration,
  }) {
    final serial = ++_serial;
    _notification = NotificationWidget(
      key: ValueKey(serial),
      message: message,
      kind: kind,
      onClose: dismiss,
    );
    _show();
    // Los errores se leen con más calma.
    final wait = duration ??
        (kind == NotificationKind.error
            ? const Duration(seconds: 6)
            : const Duration(seconds: 4));
    Future.delayed(wait, () {
      if (serial == _serial) _hide();
    });
  }

  Future<bool> confirm({required String message, String buttonText = "Confirmar"}) async {
    _serial++;
    var confirmationWidget = ConfirmationWidget(message: message, buttonText: buttonText);
    _notification = confirmationWidget;
    _show();
    var res = await confirmationWidget.confirm();
    _hide();
    return res;
  }
}
