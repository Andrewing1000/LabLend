import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:frontend/settings.dart'; // Make sure to replace with your actual settings file

class RequestHandler {
  final Dio _dio;
  final CookieJar _cookieJar = CookieJar();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  RequestHandler()
      : _dio = Dio(BaseOptions(
    baseUrl: serverURL, // Replace with your server URL
    headers: {
      'Content-Type': 'application/json',
    },
  )) {
    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Fetch CSRF token from cookies
        var cookies = await _cookieJar.loadForRequest(Uri.parse(serverURL));
        var csrfToken = cookies.firstWhere(
              (cookie) => cookie.name == 'csrftoken',
          orElse: () => Cookie('csrftoken', ''),
        ).value;

        // Add CSRF token to headers if available
        if (csrfToken.isNotEmpty) {
          options.headers['X-CSRFToken'] = csrfToken;
        }

        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle errors if necessary
        handler.next(error);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
    ));
  }

  Uri getUri(String path) {
    return Uri.http(serverURL+path);
  }

  Future<Response> getRequest(String path,
      {Map<String, dynamic> query = const {},
        Map<String, dynamic> extraH = const {}}) async {
    return _dio.get(
      path,
      queryParameters: query,
      options: Options(headers: extraH),
    );
  }

  Future<Response> postRequest(String path,
      {Map<String, dynamic> body = const {},
        Map<String, dynamic> extraH = const {}}) async {
    return _dio.post(
      path,
      data: json.encode(body),
      options: Options(headers: extraH),
    );
  }

  Future<Response> putRequest(String path,
      {Map<String, dynamic> body = const {},
        Map<String, dynamic> extraH = const {}}) async {
    return _dio.put(
      path,
      data: json.encode(body),
      options: Options(headers: extraH),
    );
  }

  Future<Response> patchRequest(String path,
      {Map<String, dynamic> body = const {},
        Map<String, dynamic> extraH = const {}}) async {
    return _dio.patch(
      path,
      data: json.encode(body),
      options: Options(headers: extraH),
    );
  }
}
