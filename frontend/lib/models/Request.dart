import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/settings.dart'; // Ensure this file exists and contains 'serverURL'

class RequestHandler {
  final Dio _dio;
  final CookieJar cookieJar = CookieJar();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String _csrfToken = ''; // Store CSRF token

  RequestHandler()
      : _dio = Dio(BaseOptions(
    baseUrl: kIsWeb ? serverURL_web : serverURL_phone, // Adjust base URL for web
    headers: {
      'Content-Type': 'application/json',
    },
  )) {
    if (!kIsWeb) {
      // Only add CookieManager for non-web platforms
      _dio.interceptors.add(CookieManager(cookieJar));
    }
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        //print("Request URL: ${options.uri}");

        if (!kIsWeb) {
          // Handle cookies for non-web platforms
          var cookies = await cookieJar.loadForRequest(Uri.parse(serverURL_phone));
          var csrfToken = cookies.firstWhere(
                (cookie) => cookie.name == 'csrftoken',
            orElse: () => Cookie('csrftoken', ''),
          ).value;

          //print("CSRF Token: $csrfToken");

          if (csrfToken.isNotEmpty) {
            options.headers['X-CSRFToken'] = csrfToken;
          }
        } else {
          // Use stored CSRF token if available
          //print("CSRF Token: $_csrfToken");

          if (_csrfToken.isNotEmpty) {
            options.headers['X-CSRFToken'] = _csrfToken;
          }
        }

        handler.next(options);
      },
      onError: (error, handler) async {
        print("Error: ${error.message}");
        handler.next(error);
      },
      onResponse: (response, handler) async {
        //print("Response: ${response.data}");
          // Store CSRF token from response if available
        if (response.headers.map['set-cookie'] != null) {
          print("No cookies detected");
          for (var cookie in response.headers.map['set-cookie']!) {
            if (cookie.contains('csrftoken')) {
              final foundToken = RegExp(r'csrftoken=([^;]+)').firstMatch(cookie)?.group(1);
              if (foundToken != null) {
                _csrfToken = foundToken;
                await secureStorage.write(key: 'csrftoken', value: _csrfToken);
              }
              break;
            }
          }
        }

        // Store session cookies
        await setCookiesFromResponse(response);

        handler.next(response);
      },
    ));

    _dio.options.extra['withCredentials'] = true;
  }

  Future<void> setCookiesFromResponse(Response response) async {
    // Store cookies from response
    if(!kIsWeb){
      if (response.headers.map['set-cookie'] != null) {
        for (var cookie in response.headers.map['set-cookie']!) {
          cookieJar.saveFromResponse(Uri.parse(serverURL_phone), [Cookie.fromSetCookieValue(cookie)]);
        }
      }
    }
    else{
      if (response.headers.map['set-cookie'] != null) {
        for (var cookie in response.headers.map['set-cookie']!) {
          cookieJar.saveFromResponse(Uri.parse(serverURL_web), [Cookie.fromSetCookieValue(cookie)]);
        }
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
      {Map<String, dynamic> body = const {}, Map<String, dynamic> extraH = const {}}) async {
    return _dio.post(
      path,
      data: json.encode(body),
      options: Options(headers: extraH),
    );
  }

  Future<Response> putRequest(String path,
      {Map<String, dynamic> body = const {}, Map<String, dynamic> extraH = const {}}) async {
    return _dio.put(
      path,
      data: json.encode(body),
      options: Options(headers: extraH),
    );
  }

  Future<Response> patchRequest(String path,
      {Map<String, dynamic> body = const {}, Map<String, dynamic> extraH = const {}}) async {
    return _dio.patch(
      path,
      data: json.encode(body),
      options: Options(headers: extraH),
    );
  }


  Future<bool> connectionCheck() async {
    try {
      final response = await _dio.get('/');
      // Consider any status code in the range 200-499 as a successful connection
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 500) {
        return true;
      }
      return false;
    } on DioError catch (e) {
      // Check if the DioError has a response with a status code
      if (e.response != null && e.response?.statusCode != null && e.response!.statusCode! >= 200 && e.response!.statusCode! < 500) {
        return true;
      }
      print("Connection check failed: ${e.message}");
      return false;
    }
  }

}
