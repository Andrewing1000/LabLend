import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/widgets/notification.dart';

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

  void notify({required String message, Duration duration = const Duration(seconds: 3)}){
    _notification = NotificationWidget(message: message);
    _show();
    Future.delayed(duration, (){
      displaying = false;
      _hide();
    });
  }
}