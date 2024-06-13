// cookie_csrf_handler.dart
abstract class CookieCsrfHandler {
  Future<String?> loadCsrfToken();
  Future<void> saveCsrfToken(String token);
  String? readCookie(String name);
}
