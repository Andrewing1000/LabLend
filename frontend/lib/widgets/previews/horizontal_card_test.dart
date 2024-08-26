import 'package:flutter/material.dart';
import 'package:frontend/widgets/horizontal_card.dart';
import 'package:frontend/widgets/horizontal_section.dart';

void main(){

  List<HorizontalCard> items = [
    const HorizontalCard(title: "Opcion1"),
    const HorizontalCard(title: "Opcion2"),
    const HorizontalCard(title: "Opcion3"),
    const HorizontalCard(title: "Opcion4"),
    const HorizontalCard(title: "Opcion1"),
    const HorizontalCard(title: "Opcion2"),
    const HorizontalCard(title: "Opcion3"),
    const HorizontalCard(title: "Opcion4"),
  ];



  return runApp(MaterialApp(
    home: Container(
      color: Colors.black,
      child: Center(
        //child: HorizontalCard(title: "Title"),
        child: HorizontalCardSection(items: items,),
      ),
    ),
  ));
}