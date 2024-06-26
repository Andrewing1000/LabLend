import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'card.dart';

class CardSection extends StatelessWidget {
  List<CustomCard> items;

  CardSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          ),
        ),
      ],
    );
  }
}
