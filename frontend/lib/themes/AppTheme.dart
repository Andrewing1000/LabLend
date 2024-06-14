import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';


class AppTheme{
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color.fromRGBO(33, 149, 241, 1.0) ,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromRGBO(33, 149, 241, 1.0),),
    brightness: Brightness.light,
    canvasColor: const Color.fromRGBO(21, 21, 21, 1.0),
    scaffoldBackgroundColor: Colors.black,
    fontFamily: 'Metropolis',


    textTheme: const TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Colors.white,),
      titleMedium: TextStyle(fontWeight: FontWeight.w900, fontSize: 25, color: Colors.white,),
      titleSmall: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white,),

      bodyLarge: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white,),
      bodyMedium: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.white,),
      bodySmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontSize: 13, color: Colors.white,),

      labelMedium: TextStyle(fontFamily: 'Metropolis',
          fontWeight: FontWeight.w300, fontSize: 14, color: Colors.grey)
      // Optionally, override more text styles
    ),

    inputDecorationTheme: const InputDecorationTheme(

      hintStyle: TextStyle(
        fontFamily: 'Metropolis',
        fontWeight: FontWeight.w300,
        fontSize: 14,
        color: Colors.grey,
      ),
      border: OutlineInputBorder(),
    ),
  );
}