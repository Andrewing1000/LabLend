// cookie_csrf_handler_mobile.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/RequestPlataform.dart';

class CookieHandler implements CookieCsrfHandler {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<String?> loadCsrfToken() async {
    return await _secureStorage.read(key: 'csrftoken');
  }

  @override
  Future<void> saveCsrfToken(String token) async {
    await _secureStorage.write(key: 'csrftoken', value: token);
  }

  @override
  String? readCookie(String name) {
    return null;
  }
}
