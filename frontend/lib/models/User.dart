
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/models/PasswordLink.dart';



abstract class User extends ChangeNotifier{
  int? id;
  /// Código de usuario (User ID) generado por el servidor, p. ej. usr.jperez.
  String username;
  String email;
  String nombres;
  String apellidoPaterno;
  String apellidoMaterno;
  bool isActive;
  /// La cuenta aún no eligió su contraseña con el enlace de activación (D26).
  bool activationPending = false;
  /// La cuenta se bloqueó por intentos fallidos (D23).
  bool isLocked = false;
  /// La contraseña venció (D21): debe cambiarla antes de seguir.
  bool passwordExpired = false;
  /// Cuándo vence la contraseña (90 días después de elegirla, D21). Null si
  /// la cuenta todavía no tiene contraseña.
  DateTime? passwordExpiresAt;

  /// Días que le quedan a la contraseña; negativo si ya venció.
  int? get passwordDaysLeft => passwordExpiresAt == null
      ? null
      : (passwordExpiresAt!.difference(DateTime.now()).inHours / 24).ceil();

  /// Faltan [passwordWarningDays] días o menos para que venza: se avisa.
  static const int passwordWarningDays = 7;
  bool get passwordExpiresSoon {
    final days = passwordDaysLeft;
    return !passwordExpired && days != null && days <= passwordWarningDays;
  }
  /// Nombres de todos los roles de la cuenta (D15).
  List<String> roles;
  /// Permisos de todos sus roles, según el servidor. Deciden qué opciones
  /// muestra la aplicación (D17).
  Set<String> permissions = {};
  /// Tiene un rol de seguridad: la gestión de cuentas no la modifica, ni le
  /// genera enlaces (D18, D27).
  bool securityAccount = false;

  /// La cuenta puede usar la función: alguno de sus roles la permite.
  bool can(String permission) => permissions.contains(permission);

  User({
        this.id,
        this.username = '',
        required this.email,
        required this.nombres,
        required this.apellidoPaterno,
        this.apellidoMaterno = '',
        this.isActive = true,
        List<String>? roles}) : roles = roles ?? [];

  String get name => [nombres, apellidoPaterno, apellidoMaterno]
      .where((part) => part.isNotEmpty)
      .join(' ');


  /// Cuenta tal como la devuelve el servidor. Lo que puede hacer sale de
  /// sus permisos (D17), no del nombre de sus roles.
  factory User.fromJson(Map<String, dynamic> userData){
    final User user = AccountUser(
      id: userData['id'],
      username: userData['username'] ?? '',
      email: userData['email'] ?? '',
      nombres: userData['nombres'] ?? '',
      apellidoPaterno: userData['apellido_paterno'] ?? '',
      apellidoMaterno: userData['apellido_materno'] ?? '',
      isActive : userData['is_active'] ?? true,
      roles: List<String>.from(userData['roles'] ?? const []),
    );

    user.permissions = Set<String>.from(userData['permissions'] ?? const []);
    user.securityAccount = userData['security_account'] ?? false;
    user.activationPending = userData['activation_pending'] ?? false;
    user.isLocked = userData['is_locked'] ?? false;
    user.passwordExpired = userData['password_expired'] ?? false;
    final expiresAt = userData['password_expires_at'];
    user.passwordExpiresAt =
        expiresAt is String ? DateTime.tryParse(expiresAt)?.toLocal() : null;
    return user;
  }


  /// Datos que se envían al servidor al crear o modificar la cuenta. Los
  /// permisos no van: salen de los roles.
  Map<String, dynamic> toJson(){
    return {
      'id' : id,
      'username' : username,
      'email' : email,
      'nombres' : nombres,
      'apellido_paterno' : apellidoPaterno,
      'apellido_materno' : apellidoMaterno,
      'roles' : roles,
      'is_active' : isActive,
      'activation_pending' : activationPending,
      'is_locked' : isLocked,
      'password_expired' : passwordExpired,
      'security_account' : securityAccount,
    };
  }

  User clone(){
    final copy = User.fromJson(toJson());
    copy.permissions = Set.of(permissions);
    return copy;
  }


  /// Crea la cuenta sin contraseña y devuelve su enlace de activación (D26).
  Future<PasswordLink?> create() async {
    return await SessionManager.userManager.createUser(this);
  }

  Future<User?> update({required User newUser}) async {
    return await SessionManager.userManager.updateUser(this, newUser: newUser);
  }

  Future<PasswordLink?> createPasswordLink() async {
    return await SessionManager.userManager.createPasswordLink(this);
  }

  void deactivate(){
    SessionManager.userManager.disableUser(this);
  }

  void activate(){
    SessionManager.userManager.enableUser(this);
  }


  void updateData({required User newUser}) {
    username = newUser.username;
    email = newUser.email;
    nombres = newUser.nombres;
    apellidoPaterno = newUser.apellidoPaterno;
    apellidoMaterno = newUser.apellidoMaterno;
    isActive =  newUser.isActive;
    roles = List.of(newUser.roles);
    permissions = Set.of(newUser.permissions);
    securityAccount = newUser.securityAccount;
    activationPending = newUser.activationPending;
    isLocked = newUser.isLocked;
    passwordExpired = newUser.passwordExpired;
    notifyListeners();
  }
}

/// Sin sesión: solo consulta el catálogo.
class VisitorUser extends User{
  static

  User anonymousUser = VisitorUser(email: "", nombres: "", apellidoPaterno: "");

  VisitorUser({required super.email, required super.nombres,
    required super.apellidoPaterno, super.id});
}

/// Cuenta del sistema, con cualquier combinación de roles.
class AccountUser extends User{
  AccountUser({super.username, required super.email, required super.nombres,
    required super.apellidoPaterno, super.apellidoMaterno, super.isActive,
    super.id, super.roles});
}
