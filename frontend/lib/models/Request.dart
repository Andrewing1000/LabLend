import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/settings.dart';

class RequestHandler extends http.BaseClient{

    http.Client client = http.Client();

    Uri getUri(String path){
        return Uri.http(serverURL, path);
    }

    Map<String, String> getHeaders({Map<String, dynamic> extra = const {}}){

      Map<String, String> headers = {};
      headers['Content-Type'] =  'application/json';

      return {...headers, ...extra};
    }


    Future<http.Response> getRequest(String path,
        {Map<String, dynamic> query = const {},
         Map<String, dynamic> extraH = const {}}) async {

      Uri url = getUri(path);
      Uri queryUri = Uri.http(url.authority, url.path, query);
      
      final response = await client.get(queryUri,
                                        headers: getHeaders(extra: extraH));
        
      return response;
    }

    Future<http.Response> postRequest(String path,
        {Map<String, dynamic> body = const {},
         Map<String, dynamic> extraH = const {}}) async{
        final response = await client.post(getUri(path),
                                           headers: getHeaders(extra: extraH),
                                           body: json.encode(body));
        return response;
    }

    Future<http.Response> putRequest(String path,
        {Map<String, dynamic> body = const {},
          Map<String, dynamic> extraH = const {}}) async{
      final response = await client.put(getUri(path),
          headers: getHeaders(extra: extraH),
          body: json.encode(body));
      return response;
    }

    Future<http.Response> patchRequest(String path,
        {Map<String, dynamic> body = const {},
          Map<String, dynamic> extraH = const {}}) async{
      final response = await client.patch(getUri(path),
          headers: getHeaders(extra: extraH),
          body: json.encode(body));
      return response;
    }

    @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return client.send(request);
  }
}