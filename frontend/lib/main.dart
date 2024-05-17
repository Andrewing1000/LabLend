import 'package:flutter/material.dart';
import 'models/Request.dart';Future<void> main() async {
  RequestHandler requestHandler =  RequestHandler();

  var data = {
    'email' : 'admin@example.com',
    'password' : '#123#AndresHinojosa#123',
  };

  var response = await requestHandler.postRequest('/api/user/token/', body: data);

  print(response.statusCode);
  print(response.body);

  response = await requestHandler.getRequest('/api/user/list');
  print(response.statusCode);
  print(response.body);
  //runApp(const MyApp());
}
