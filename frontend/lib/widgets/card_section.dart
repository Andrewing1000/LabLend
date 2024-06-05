import 'package:flutter/material.dart';

class CardSection extends StatelessWidget {
  final List<Widget> items;

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
          "Instrumentos de Laboratorio",
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          height: 300, // Ajusta según sea necesario
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: items,
          ),
        ),
      ],
    );
  }
}
