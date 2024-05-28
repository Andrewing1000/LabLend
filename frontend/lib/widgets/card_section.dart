import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'card.dart';

<<<<<<< HEAD
// ignore: must_be_immutable
class CardSection extends StatelessWidget{
=======
class CardSection extends StatelessWidget {
>>>>>>> Pruebas
  List<CustomCard> items;

  CardSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
<<<<<<< HEAD
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 30,),
          const Text("Section",
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 30,
                color: Colors.white),),
          const SizedBox(height: 30,),
          SizedBox(
            height: CustomCard.height,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: items,
            ),
=======
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
        ),
        Text(
          "Section",
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          height: CustomCard.height,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: items,
>>>>>>> Pruebas
          ),
        ),
      ],
    );
  }
}
