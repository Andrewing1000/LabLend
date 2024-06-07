import 'dart:core';

import 'package:frontend/models/Request.dart';
import 'package:dio/dio.dart';
import 'package:frontend/models/UserManager.dart';
import 'package:frontend/screens/main_frame.dart';
import 'package:frontend/services/ContextMessageService.dart';
import 'Inventory.dart';
import 'item.dart';
import 'LoanService.dart';
import 'User.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Session {
  static final SessionManager manager = SessionManager();
  final Widget mainFrame = SessionManager.mainFrame;
  final RequestHandler requestHandler = SessionManager.httpHandler;

  final User user;
  final DateTime loginTime;

  Session({required this.user, required this.loginTime});

  void logIn(String password) {
    manager.login(user.email, password);
  }

  void logOut() {
    if (manager.session == this) {
      manager.logOut();
    }
  }

  Future<bool> sessionCheck() async {
    return await manager.sessionCheck();
  }

  Future<bool> connectionCheck() async {
    return await manager.connectionCheck();
  }

  bool isAdmin() {
    if (user is AdminUser) {
      return true;
    }
    manager.errorNotification(error: "Acción denegada");
    return false;
  }

  Future<bool> isReady() async {
    //Implement login
    return await connectionCheck();
  }
}

class AnonymousSession extends Session {
  AnonymousSession()
      : super(user: VisitorUser.anonymousUser, loginTime: DateTime.now());
}

class SessionManager with ChangeNotifier {
  static SessionManager _manager = SessionManager._inner();

  static RequestHandler httpHandler = RequestHandler();
  static UserManager userManager = UserManager();
  static Inventory inventory = Inventory();
  static LoanService loanService = LoanService();
  static ContextMessageService messageService = ContextMessageService();
  static MainFrame mainFrame = MainFrame(messageService: messageService);

  Session _session = AnonymousSession();
  bool _isOnline = false;

  SessionManager._inner() {
    connectionCheck();
  }

  factory SessionManager() {
    _manager ??= SessionManager._inner();
    return _manager;
  }

  Session get session => _session;

  bool get isOnline => _isOnline;
  set isOnline(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  ///
  ///
  ///
  /// Notify MainFrame
  void errorNotification(
      {required String error, Map<String, dynamic>? details}) {
    String message = "$error";
    if (details != null) {
      String detail = formatDjangoErrors(details);
      message = "$message\n$detail";
    }
    messageService.notify(message: message);
  }

  void notification({required String notification}) {
    messageService.notify(message: notification);
  }

  void confirmNotification() {}

  ///
  ///
  ///
  ///Online status manager
  Future<bool> connectionCheck() async {
    var connectionRes;
    try {
      connectionRes = await httpHandler.connectionCheck();
      if (!isOnline) errorNotification(error: 'Sin conexión');
      if (connectionRes == isOnline) return isOnline;
      isOnline = connectionRes;
    } catch (e) {
      isOnline = false;
    }

    if (!isOnline) errorNotification(error: 'Sin conexión');
    return isOnline;
  }

  Future<bool> sessionCheck() async {
    try {
      var response = await httpHandler.getRequest('/user/me/');
      if (response.statusCode == 200) {
        return true;
      }
    } on DioException catch (e) {
      print(e.stackTrace);
    }

    _session = AnonymousSession();
    errorNotification(error: 'Inicie sesión');
    notifyListeners();
    return false;
  }

  ///
  ///
  ///
  ///Login management
  Future<Session> login(String email, String password) async {
    if (!(await connectionCheck())) {
      return AnonymousSession();
    }
    ;

    if (_session is! AnonymousSession) {
      if (await sessionCheck()) {
        if (_session?.user.email == email) {
          notification(notification: "Ya ha iniciado seción.");
          return _session;
        } else {
          if (session is! AnonymousSession)
            await httpHandler.postRequest('/user/logout/');
        }
      }
    }

    Map<String, String> data = {
      'email': email,
      'password': password,
    };

    try {
      var response = await httpHandler.postRequest('/user/token/', body: data);
      User user = User.fromJson(response.data);

      if (!user.isActive) {
        errorNotification(error: 'La cuenta no está habilitada');
        return AnonymousSession();
      }

      notification(notification: 'Sesión iniciada');
      _session = Session(user: user, loginTime: DateTime.now());
      notifyListeners();
      return _session;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        errorNotification(error: 'Usuario no registrado');
        //Not found
        return AnonymousSession();
      } else if (e.response?.statusCode == 401) {
        //Bad credentials
        errorNotification(error: 'Credenciales inválidas');
        return AnonymousSession();
      } else if (e.response?.statusCode == 429) {
        //Too many attempts
        errorNotification(error: 'Muchos intentos, intente de nuevo más tarde');
        return AnonymousSession();
      } else {
        print("Unknown Error");
        return AnonymousSession();
      }
    }
  }

  Future<Session> logOut() async {
    if (!(await connectionCheck())) {
      return AnonymousSession();
    }
    if (!(await sessionCheck())) {
      return AnonymousSession();
    }

    var response = await httpHandler.postRequest('/user/logout/');

    if (response.statusCode == 200) {
      errorNotification(error: 'Sesión cerrada');
      print("Hasta aqui llegamos");
      mainFrame = MainFrame(messageService: messageService);
      _session = AnonymousSession();
    } else if (response.statusCode == 412) {
      errorNotification(error: 'Primero inicie sesión');
      _session = AnonymousSession();
    } else {
      print("Hasta aqui llegamos");
      mainFrame = MainFrame(messageService: messageService);
      errorNotification(error: 'Sesión cerrada');
      _session = AnonymousSession();
    }

    notifyListeners();
    return _session;
  }

  String formatDjangoErrors(Map<String, dynamic> errorDict) {
    List<String> formattedErrors = [];

    void processErrors(String key, dynamic errors) {
      if (errors is List) {
        for (var error in errors) {
          formattedErrors.add(_beautifyMessage(key, error));
        }
      } else if (errors is Map) {
        errors.forEach((subKey, subErrors) {
          processErrors('$key.$subKey', subErrors);
        });
      } else {
        formattedErrors.add(_beautifyMessage(key, errors));
      }
    }

    errorDict.forEach((field, errorList) {
      processErrors(field, errorList);
    });

    return formattedErrors.join('\n');
  }

  String _beautifyMessage(String field, String error) {
    String beautifiedField = _prettifyFieldName(field);
    return "$beautifiedField: $error";
  }

  String _prettifyFieldName(String field) {
    return field.split('.').map((part) {
      return part.split('_').map((word) {
        return word[0].toUpperCase() + word.substring(1);
      }).join(' ');
    }).join(' -> ');
  }
}
