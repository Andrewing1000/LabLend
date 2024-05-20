import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'card.dart';

// ignore: must_be_immutable
class CardSection extends StatelessWidget{
  List<CustomCard> items;

  CardSection({super.key, required this.items});

  @override
  Widget build(BuildContext context){
    return Column(
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
          ),
        ],
      );
  }
}