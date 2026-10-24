import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:core';

import 'package:frontend/models/Request.dart';
import 'package:dio/dio.dart';
import 'package:frontend/models/UserManager.dart';
import 'package:frontend/screens/main_frame.dart';
import 'package:frontend/services/ContextMessageService.dart';
import 'Inventory.dart';
import 'LoanService.dart';
import 'Role.dart';
import 'User.dart';
import 'package:flutter/material.dart';

class Session {
  static final SessionManager manager = SessionManager();
  final Widget mainFrame = SessionManager.mainFrame;
  final RequestHandler requestHandler = SessionManager.httpHandler;

  final User user;
  final DateTime loginTime;

  Session({required this.user, required this.loginTime});


  void logIn(String password){
    manager.login(user.username, password);
  }
  void logOut(){
    if(manager.session == this){
      manager.logOut();
    }
  }

  Future<bool> sessionCheck() async {
    return await manager.sessionCheck();
  }

  Future<bool> connectionCheck() async{
    return await manager.connectionCheck();
  }

  /// La cuenta tiene el permiso (D17). Si no, avisa y no envía la petición,
  /// que el servidor rechazaría de todos modos.
  bool allowed(String permission){
    if(user.can(permission)){
      return true;
    }
    manager.errorNotification(error: "Acción denegada");
    return false ;
  }

  Future<bool> isReady() async{
    //Implement login
    return await connectionCheck();
  }

}


class AnonymousSession extends Session{
  AnonymousSession():super(user: VisitorUser.anonymousUser, loginTime: DateTime.now());
}


class SessionManager with ChangeNotifier {
  static SessionManager _manager = SessionManager._inner();

  static RequestHandler httpHandler = RequestHandler();
  static UserManager userManager = UserManager();
  static RoleService roleService = RoleService();
  static Inventory inventory = Inventory();
  static LoanService loanService = LoanService();
  static ContextMessageService messageService = ContextMessageService();
  static MainFrame mainFrame = MainFrame(messageService: messageService);

  Session _session = AnonymousSession();
  bool _isOnline = false;

  SessionManager._inner(){
    connectionCheck();
    restoreSession();
  }

  /// Recupera la sesión al recargar la página. La cookie de sesión es
  /// HttpOnly (D7): la aplicación no puede leerla, pero el navegador la
  /// envía, así que se pregunta al servidor quién es el usuario. Si la
  /// sesión venció (15 minutos) o no hay, se sigue como visitante sin avisar.
  /// Aviso de que la contraseña está por vencer (D21): se da al entrar,
  /// para que el usuario la cambie antes de que el sistema lo obligue.
  void _warnPasswordExpiry(User user) {
    if (!user.passwordExpiresSoon) return;
    final days = user.passwordDaysLeft!;
    warningNotification(
        warning: days <= 0
            ? 'Su contraseña vence hoy. Cámbiela desde Mi perfil.'
            : 'Su contraseña vence en $days ${days == 1 ? 'día' : 'días'}. '
                'Cámbiela desde Mi perfil.');
  }

  Future<void> restoreSession() async {
    if (_session is! AnonymousSession) return;
    try {
      final response = await httpHandler.getRequest('/user/me/');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>
          && _session is AnonymousSession) {
        _session = Session(user: User.fromJson(response.data), loginTime: DateTime.now());
        notifyListeners();
        _warnPasswordExpiry(_session.user);
      }
    } on DioException catch (_) {
      // Sin sesión (403) o sin conexión: queda como visitante.
    }
  }

  factory SessionManager(){
    _manager ??= SessionManager._inner();
    return _manager;
  }

  Session get session => _session;

  bool get isOnline => _isOnline;
  set isOnline(bool online){
    _isOnline = online;
    notifyListeners();
  }
  ///
  ///
  ///
  /// Notify MainFrame
  void errorNotification({required String error, Map<String, dynamic>? details}){
    String message = error;
    if(details != null){
      String detail = formatDjangoErrors(details);
      message = "$message\n$detail";
    }
    messageService.notify(message: message, kind: NotificationKind.error);
  }

  /// Aviso de que algo salió bien (por defecto) o informativo.
  void notification({
    required String notification,
    NotificationKind kind = NotificationKind.success,
  }){
    messageService.notify(message: notification, kind: kind);
  }

  void warningNotification({required String warning}){
    messageService.notify(message: warning, kind: NotificationKind.warning);
  }

  Future<bool> confirmNotification({required String message}) async {
    return await messageService.confirm(message: message);
  }


  ///
  ///
  ///
  ///Online status manager
  Future<bool> connectionCheck() async{

    bool connectionRes;
    try{
      connectionRes = await httpHandler.connectionCheck();
      if(connectionRes == isOnline) return isOnline;
      isOnline = connectionRes;
    }catch (e){
      isOnline = false;
    }

    if(!isOnline) errorNotification(error : 'Sin conexión con el servidor. Algunas funciones no están disponibles.');
    return isOnline;
  }

  Future<bool> sessionCheck() async{
    try{
      var response = await httpHandler.getRequest('/user/me/');
      if(response.statusCode == 200){
        _refreshPermissions(response.data);
        return true;
      }
    }on DioException catch (e){
      if (kDebugMode) debugPrint(e.stackTrace.toString());
    }

    _session = AnonymousSession();
    errorNotification(error: 'Inicie sesión');
    notifyListeners();
    return false;
  }


  /// Si cambiaron los roles o los permisos de la cuenta mientras tenía la
  /// sesión abierta, el menú se actualiza sin volver a iniciar sesión.
  void _refreshPermissions(dynamic data){
    if(data is! Map || _session is AnonymousSession) return;
    final user = _session.user;
    final permissions = Set<String>.from(data['permissions'] ?? const []);
    final roles = List<String>.from(data['roles'] ?? const []);
    if(permissions.length == user.permissions.length
        && permissions.containsAll(user.permissions)
        && roles.join(',') == user.roles.join(',')){
      return;
    }
    user.permissions = permissions;
    user.roles = roles;
    notifyListeners();
  }


  ///
  ///
  ///
  ///Login management
  Future<Session> login(String username, String password) async {
    if(!(await connectionCheck())){return AnonymousSession();}
    username = username.trim().toLowerCase();

    if(_session is! AnonymousSession){
      if(await sessionCheck()){
        if(_session.user.username == username){
          notification(notification: "Ya ha iniciado sesión.", kind: NotificationKind.info);
          return _session;
        }
        else{
          if(session is! AnonymousSession) await httpHandler.postRequest('/user/logout/');
        }
      }
    }

    Map<String, String> data = {
      'username' : username,
      'password' : password,
    };

    try{
      var response = await httpHandler.postRequest('/user/token/', body: data);
      User user = User.fromJson(response.data);

      if(!user.isActive){
        errorNotification(error :'La cuenta no está habilitada');
        return AnonymousSession();
      }

      _session = Session(user: user, loginTime: DateTime.now());
      notifyListeners();
      // Si la contraseña está por vencer, ese aviso reemplaza al de bienvenida.
      if (user.passwordExpiresSoon) {
        _warnPasswordExpiry(user);
      } else {
        notification(notification : 'Sesión iniciada');
      }
      return _session;

    } on DioException catch(e){

      if(e.response?.statusCode == 401){

        // El servidor no distingue entre código inexistente y contraseña
        // incorrecta (D12): se muestra su mensaje genérico.
        final data = e.response?.data;
        errorNotification(error: data is Map && data['message'] is String
            ? data['message']
            : 'Código de usuario o contraseña incorrectos');
        return AnonymousSession();
      }
      else if(e.response?.statusCode == 429){

        //Too many attempts
        errorNotification(error :'Muchos intentos, intente de nuevo más tarde');
        return AnonymousSession();
      }
      else{

        if (kDebugMode) debugPrint("Unknown Error");
        return AnonymousSession();
      }
    }
  }


  /// Cambia la contraseña propia, confirmando la actual (D14). Si estaba
  /// vencida (D21), la aplicación vuelve a quedar disponible. El servidor
  /// mantiene abierta esta sesión.
  Future<bool> changeOwnPassword(
      String currentPassword, String newPassword) async {
    dynamic data;
    try {
      final response = await httpHandler.patchRequest('/user/me/', body: {
        'current_password': currentPassword,
        'password': newPassword,
      });
      data = response.data;
    } on DioException catch (e) {
      errorNotification(
          error: 'No se pudo cambiar la contraseña',
          details: e.response?.data);
      return false;
    }
    _session.user.passwordExpired = false;
    // La contraseña nueva empieza otros 90 días: el servidor devuelve la fecha.
    final expiresAt = data is Map ? data['password_expires_at'] : null;
    _session.user.passwordExpiresAt = expiresAt is String
        ? DateTime.tryParse(expiresAt)?.toLocal()
        : DateTime.now().add(const Duration(days: 90));
    notification(notification: 'Contraseña cambiada');
    notifyListeners();
    return true;
  }

  Future<Session> logOut() async{
    if(!(await connectionCheck())){
      return AnonymousSession();
    }
    if(!(await sessionCheck())){
      return AnonymousSession();
    }

    var response = await httpHandler.postRequest('/user/logout/');

    if(response.statusCode == 200){
      notification(notification: 'Sesión cerrada', kind: NotificationKind.info);
      mainFrame = MainFrame(messageService: messageService);
      _session = AnonymousSession();
    }
    else if(response.statusCode == 412){
      errorNotification(error :'Primero inicie sesión');
      _session = AnonymousSession();
    }
    else{
      mainFrame = MainFrame(messageService: messageService);
      notification(notification: 'Sesión cerrada', kind: NotificationKind.info);
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
    // Mensajes generales del servidor (403, reglas del modelo): sin campo.
    if (field == 'detail' || field == 'non_field_errors') return error;
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