import 'dart:html' as html;
import 'package:frontend/services/RequestPlataform.dart';


class CookieHandler implements CookieCsrfHandler {
  @override
  Future<String?> loadCsrfToken() async {
    return readCookie('csrftoken');
  }

  @override
  Future<void> saveCsrfToken(String token) async {
    // Generalmente no es necesario guardar el CSRF token por separado en web
  }

  @override
  String? readCookie(String name) {
    String cookies = html.document.cookie ?? "";
    for (String cookie in cookies.split(";")) {
      List<String> parts = cookie.split("=");
      if (parts[0].trim() == name) {
        return parts[1].trim();
      }
    }
    return null;
  }
}
