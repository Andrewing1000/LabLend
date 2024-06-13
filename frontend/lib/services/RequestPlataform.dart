
import  'package:frontend/services/MobileCookies.dart'
if(dart.library.html) 'package:frontend/services/WebCookies.dart';



abstract class CookieCsrfHandler {
  Future<String?> loadCsrfToken();
  Future<void> saveCsrfToken(String token);
  String? readCookie(String name);

  factory CookieCsrfHandler.fromPlatform(){
    return CookieHandler() as CookieCsrfHandler;
  }
}
