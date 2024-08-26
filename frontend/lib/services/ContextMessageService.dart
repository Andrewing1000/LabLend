import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/widgets/notificacion.dart';
import 'package:frontend/widgets/notificationCard.dart';

class ContextMessageService extends ChangeNotifier{
  NotificationWidget? _notification;
  bool displaying;

  ContextMessageService({this.displaying = false});

  NotificationWidget? get notification => _notification;

  void _show(){
    displaying = true;
    notifyListeners();
  }

  void _hide(){
    displaying = false;
    notifyListeners();
  }

  void focusLost(){
    if(_notification is ConfirmationWidget){
      final confirmationWidget = (_notification as ConfirmationWidget);
      confirmationWidget.completer.complete(false);
      displaying = false;
    }
    notifyListeners();
  }

  void notify({required String message, Duration duration = const Duration(seconds: 3)}){
    _notification = NotificationWidget(message: message);
    _show();
    Future.delayed(duration, (){
      _hide();
    });
  }

  Future<bool> confirm({required String message, String buttonText = "Confirmar"}) async{
    var confirmationWidget = ConfirmationWidget(message: message, buttonText: buttonText);
    _notification = confirmationWidget;
    _show();
    var res = await confirmationWidget.confirm();
    _hide();
    return res;
  }
}