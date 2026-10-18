/// Enlace de contraseña que genera el servidor (D24, D26). Se muestra una
/// sola vez: el servidor guarda solo su hash.
class PasswordLink {
  static const String activation = 'activacion';
  static const String reset = 'restablecimiento';

  final String username;
  final String url;
  final String purpose;

  const PasswordLink(
      {required this.username, required this.url, required this.purpose});

  bool get isActivation => purpose == activation;

  factory PasswordLink.fromJson(String username, Map<String, dynamic> data) {
    return PasswordLink(
        username: username, url: data['url'], purpose: data['purpose']);
  }
}
