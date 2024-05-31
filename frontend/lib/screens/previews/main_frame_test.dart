import 'package:flutter/material.dart';
import 'package:frontend/screens/main_frame.dart';
import 'package:frontend/services/ContextMessageService.dart';


void main(){
  return runApp(MaterialApp(
    home: Scaffold(
      body: MainFrame(messageService: ContextMessageService(),),
    ) ,
  ));
}