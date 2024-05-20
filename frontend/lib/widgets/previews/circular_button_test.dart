import 'package:flutter/material.dart';

import 'package:frontend/widgets/cicular_button.dart';


class Test extends StatefulWidget{
  const Test({super.key});

  @override
  State<Test> createState(){
    return TestState();
  }
}


class TestState extends State<Test>{
  bool selectedNot = true;
  bool selectedPeople = false;
  bool available = true;

  @override
  Widget build(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
          CircularButton.animated(
            normalIcon: Icons.notifications_none_outlined,
            selectedIcon: Icons.notifications,
            isSelected: selectedNot,
            isAvailable: available,
            size : 40,
            onPressed: (){
              setState(() {
                print("notis");
                selectedNot = !selectedNot;
              });

            },
          ),
          const SizedBox(
              height: 30,
          ),
          CircularButton.static(
              normalIcon: Icons.people,
              isSelected: selectedPeople,
              isAvailable: available,
              size: 40,
              onPressed: (){
                setState(() {
                  print("people");
                  selectedPeople = !selectedPeople;
                });
              }
           ),

        CircularButton.static(
            normalIcon: Icons.block,
            selectedIcon: Icons.check,
            isSelected: available,

            size: 40,
            onPressed: (){
              setState(() {
                print("enable");
                available = !available;
              });
            }
        ),
      ],
    );
  }
}




void main(){
  return runApp(
    MaterialApp(
      home: Container(
        color: Colors.orange,
        child: Test(),
      ),
    )
  );
}