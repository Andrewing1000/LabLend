import "package:flutter/material.dart";

import "../CustomDatePicker.dart";

void main(){
  return runApp(App());
}


class App extends StatelessWidget {

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