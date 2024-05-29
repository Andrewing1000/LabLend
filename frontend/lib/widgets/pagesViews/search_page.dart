import 'package:flutter/material.dart';
import 'package:frontend/widgets/card.dart';
import 'package:frontend/widgets/pagesViews/search_container_list.dart';

import '../barra_busqueda.dart';

// ignore: must_be_immutable
class SearchPage extends StatefulWidget {
  String query;

  SearchPage({super.key, required this.query});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  InputFillResponse input = InputFillResponse();

  List<CustomCard> cItems = [
    CustomCard(
      title: "Maquina 1",
      subtitle: 'Maquina',
    ),
    CustomCard(
      title: "Pizarra",
      subtitle: 'Pizarra',
    ),
    CustomCard(
      title: "Marraqueta",
      subtitle: 'Pizarra',
    ),
    CustomCard(
      title: "Proveta",
      subtitle: 'Maquina 2',
    ),
    CustomCard(
      title: "Maquina 1",
      subtitle: 'Maquina',
    ),
    CustomCard(
      title: "Pantera",
      subtitle: 'Pizarra',
    ),
    CustomCard(
      title: "Carnaval",
      subtitle: 'Pizarra',
    ),
    CustomCard(
      title: "MAquina 2",
      subtitle: 'Maquina 2',
    ),
    CustomCard(
      title: "Maquina 1",
      subtitle: 'Maquina',
    ),
    CustomCard(
      title: "Pizarra",
      subtitle: 'Pizarra',
    ),
    CustomCard(
      title: "Marron",
      subtitle: 'Pizarra',
    ),
    CustomCard(
      title: "MAquina 2",
      subtitle: 'Maquina 2',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    //String busqueda;
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Center(
          child: Container(
            height: size.height * 0.88,
            width: size.width * 0.88,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text(
                Container(
                  height: 110,
                ),

                Expanded(
                  child: SearchResultsContent(
                    misItems: cItems,
                    query: widget.query,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
