import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/settings.dart'; // Ensure this file exists and contains 'serverURL'
import 'dart:html' as html;

class RequestHandler {
  final Dio _dio;
  final CookieJar cookieJar = CookieJar();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String _csrfToken = ''; // Store CSRF token

  RequestHandler()
      : _dio = Dio(
                  BaseOptions(
                    baseUrl: kIsWeb ? serverURL_web : serverURL_phone, // Adjust base URL for web
                    headers: {
                      'Content-Type': 'application/json',
                    },
                  )
                )
  {

    _dio.options.extra['withCredentials'] = true;
    if(!kIsWeb){
      _dio.interceptors.add(CookieManager(cookieJar));
      _loadCookies();
    }
    else{
      _loadCsrfToken();
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!kIsWeb) {
          var cookies = await cookieJar.loadForRequest(Uri.parse(serverURL_phone));
          var csrfToken = cookies.firstWhere(
                (cookie) => cookie.name == 'csrftoken',
            orElse: () => Cookie('csrftoken', ''),
          ).value;

          if (csrfToken.isNotEmpty) {
            print("Phone cookie found");
            options.headers['X-CSRFToken'] = csrfToken;
          }
          else{
            print("Phone cookie NOT found");
          }
        } else {
          _loadCsrfToken();
          if (_csrfToken.isNotEmpty) {
            print("Web cookie found");
            options.headers['X-CSRFToken'] = _csrfToken;
          }
          else{
            String? csrfToken = readCookie('csrftoken');
            options.headers['X-CSRFToken'] = csrfToken;
            print("Web cookie NOT found");
          }
        }

        handler.next(options);
      },
      onError: (error, handler) async {
        print("Error: ${error.message}");
        handler.next(error);
      },
      onResponse: (response, handler) async {
        // Debug: Print all headers
        // Usage
        // Store CSRF token from response if available
        if (response.headers.map.containsKey('set-cookie')) {
          print('Set-Cookie found');
          for (var cookie in response.headers['set-cookie']!) {
            print('Cookie: $cookie');
            if (cookie.contains('csrftoken')) {
              final foundToken = RegExp(r'csrftoken=([^;]+)').firstMatch(cookie)?.group(1);
              if (foundToken != null) {
                _csrfToken = foundToken;
                await secureStorage.write(key: 'csrftoken', value: _csrfToken);
              }
            }
          }
        } else {
          print('Set-Cookie NOT found');
        }
        // Store session cookies
        await setCookiesFromResponse(response);

        handler.next(response);
      },
    ));
  }

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


  Future<void> _loadCookies() async {
    try {
      String? cookiesString = await secureStorage.read(key: 'cookies');
      if (cookiesString != null) {
        List<Cookie> cookies = (json.decode(cookiesString) as List)
            .map((cookie) => Cookie.fromSetCookieValue(cookie))
            .toList();
        cookieJar.saveFromResponse(Uri.parse(serverURL_phone), cookies);
      }
    } catch (e) {
      print("Error loading cookies from secure storage: $e");
    }
  }

  Future<void> _loadCsrfToken() async {
    try {
      _csrfToken = await secureStorage.read(key: 'csrftoken') ?? '';
    } catch (e) {
      print("Error loading CSRF token from secure storage: $e");
    }
  }

  Future<void> _saveCookies() async {
    try {
      List<Cookie> cookies = await cookieJar.loadForRequest(Uri.parse(serverURL_phone));
      List<String> cookiesString = cookies.map((cookie) => cookie.toString()).toList();
      await secureStorage.write(key: 'cookies', value: json.encode(cookiesString));
    } catch (e) {
      print("Error saving cookies to secure storage: $e");
    }
  }

  Future<void> setCookiesFromResponse(Response response) async {
    if (!kIsWeb) {
      if (response.headers.map['set-cookie'] != null) {
        List<Cookie> cookies = response.headers.map['set-cookie']!
            .map((cookie) => Cookie.fromSetCookieValue(cookie))
            .toList();
        await cookieJar.saveFromResponse(Uri.parse(serverURL_phone), cookies);
        await _saveCookies();
      }
    } else {
      if (response.headers.map['set-cookie'] != null) {
        List<Cookie> cookies = response.headers.map['set-cookie']!
            .map((cookie) => Cookie.fromSetCookieValue(cookie))
            .toList();
        // No need to save cookies in secure storage for web
      }
    }
  }

  Future<Response> getRequest(String path,
      {Map<String, dynamic> query = const {}, Map<String, dynamic> extraH = const {}}) async {
    return _dio.get(
      path,
      queryParameters: query,
      options: Options(headers: extraH),
    );
  }

  Future<Response> postRequest(String path,
      {Map<String, dynamic> body = const {}}) async {
    return _dio.post(
      path,
      data: json.encode(body),
    );
  }

  Future<Response> putRequest(String path,
      {Map<String, dynamic> body = const {}, Map<String, dynamic>  query = const {}}) async {
    return _dio.put(
      path,
      data: json.encode(body),
      queryParameters: query,
    );
  }

  Future<Response> patchRequest(String path,
      {Map<String, dynamic> body = const {}, Map<String, dynamic>  query = const {}}) async {
    return _dio.patch(
      path,
      data: json.encode(body),
      queryParameters: query,
    );
  }

  Future<bool> connectionCheck() async {
    return true;
  }
}
