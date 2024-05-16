import 'package:flutter/material.dart';
import 'package:frontend/widgets/horizontal_card.dart';
import 'package:frontend/widgets/horizontal_section.dart';

void main(){

  List<HorizontalCard> items = [
    HorizontalCard(title: "Opcion1"),
    HorizontalCard(title: "Opcion2"),
    HorizontalCard(title: "Opcion3"),
    HorizontalCard(title: "Opcion4"),
    HorizontalCard(title: "Opcion1"),
    HorizontalCard(title: "Opcion2"),
    HorizontalCard(title: "Opcion3"),
    HorizontalCard(title: "Opcion4"),
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