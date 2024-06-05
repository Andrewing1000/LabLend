import "package:flutter/material.dart";

import "../CustomDatePicker.dart";

void main(){
  return runApp(const App());
}


class App extends StatelessWidget {
  const App({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: CustomDatePicker(
          firstDate: DateTime(2001),
          lastDate: DateTime(2010),
          onDateChanged: (dt) {},)
    );
  }
}