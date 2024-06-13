import 'package:flutter/material.dart';


void main(){
  runApp(StackTest());
}


class StackTest extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.yellow,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  //Container(color: Colors.red,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}