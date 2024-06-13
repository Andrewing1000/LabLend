import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:frontend/settings.dart';

import '../services/RequestPlataform.dart';

class RequestHandler {
  final Dio _dio;
  final CookieJar cookieJar = CookieJar();
  final CookieCsrfHandler _cookieCsrfHandler;
  String _csrfToken = ''; // Store CSRF token

  RequestHandler()
      : _dio = Dio(
      BaseOptions(
        baseUrl: kIsWeb ? serverURL_web : serverURL_phone, // Ajusta la URL base para la web
      )),
    _cookieCsrfHandler = CookieCsrfHandler.fromPlatform() {
    _dio.options.extra['withCredentials'] = true;

    if (!kIsWeb) {
      _dio.interceptors.add(CookieManager(cookieJar));
      _loadCookies();
    } else {
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
            options.headers['X-CSRFToken'] = csrfToken;
          }
        } else {
          _loadCsrfToken();
          if (_csrfToken.isNotEmpty) {
            options.headers['X-CSRFToken'] = _csrfToken;
          } else {
            String? csrfToken = _cookieCsrfHandler.readCookie('csrftoken');
            options.headers['X-CSRFToken'] = csrfToken;
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        print("Error: ${error.message}");
        handler.next(error);
      },
      onResponse: (response, handler) async {
        if (response.headers.map.containsKey('set-cookie')) {
          for (var cookie in response.headers['set-cookie']!) {
            if (cookie.contains('csrftoken')) {
              final foundToken = RegExp(r'csrftoken=([^;]+)').firstMatch(cookie)?.group(1);
              if (foundToken != null) {
                _csrfToken = foundToken;
                await _cookieCsrfHandler.saveCsrfToken(_csrfToken);
              }
            }
          }
        }
        await setCookiesFromResponse(response);

        handler.next(response);
      },
    ));
  }

  Dio get dio => _dio;

  Future<void> _loadCookies() async {
    try {
      String? cookiesString = await _cookieCsrfHandler.loadCsrfToken();
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
      _csrfToken = await _cookieCsrfHandler.loadCsrfToken() ?? '';
    } catch (e) {
      print("Error loading CSRF token from secure storage: $e");
    }
  }

  Future<void> _saveCookies() async {
    try {
      List<Cookie> cookies = await cookieJar.loadForRequest(Uri.parse(serverURL_phone));
      List<String> cookiesString = cookies.map((cookie) => cookie.toString()).toList();
      await _cookieCsrfHandler.saveCsrfToken(json.encode(cookiesString));
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
      }
    }
  }

  Future<Response> getRequest(String path,
      {Map<String, dynamic> query = const {}, Map<String, dynamic> extraH = const {}}) async {
    Map<String, dynamic> headers = {};
    headers.addAll(extraH);
    headers.addAll({'Content-Type': 'application/json',});
    return _dio.get(
      path,
      queryParameters: query,
      options: Options(headers: headers),
    );
  }

  Future<Response> postRequest(String path,
      {Map<String, dynamic> body = const {}}) async {
    Map<String, dynamic> headers = {};
    headers.addAll({'Content-Type': 'application/json',});
    return _dio.post(
      path,
      data: json.encode(body),
      options: Options(headers: headers),
    );
  }

  Future<Response> deleteRequest(String path,
      {Map<String, dynamic> body = const {}}) async {
    Map<String, dynamic> headers = {};
    headers.addAll({'Content-Type': 'application/json',});
    return _dio.delete(
      path,
      data: json.encode(body),
      options: Options(headers: headers),
    );
  }

  Future<Response> putRequest(String path,
      {Map<String, dynamic> body = const {}, Map<String, dynamic> query = const {}}) async {
    Map<String, dynamic> headers = {};
    headers.addAll({'Content-Type': 'application/json',});
    return _dio.put(
      path,
      data: json.encode(body),
      queryParameters: query,
      options: Options(headers: headers),
    );
  }

  Future<Response> patchRequest(String path,
      {Map<String, dynamic> body = const {}, Map<String, dynamic> query = const {}}) async {
    Map<String, dynamic> headers = {};
    headers.addAll({'Content-Type': 'application/json',});
    return _dio.patch(
      path,
      data: json.encode(body),
      queryParameters: query,
      options: Options(headers: headers),
    );
  }

  Future<bool> connectionCheck() async {
    try {
      final response = await _dio.get('/health_check');
      print("Server is up and responded with status code: ${response.statusCode}");
      return true;
    } catch (e) {
      print("Error during connection check: $e");
      return false;
    }
  }
}