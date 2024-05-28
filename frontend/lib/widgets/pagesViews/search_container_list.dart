import 'package:flutter/material.dart';
import 'package:frontend/widgets/card.dart';

class SearchResultsContent extends StatefulWidget {
  List<CustomCard> misItems;
  String query;

  // SearchResults({super.key, required this.itemsResult});
  SearchResultsContent(
      {super.key, required this.misItems, required this.query});

  @override
  State<SearchResultsContent> createState() => _SearchResultsContentState();
}

class _SearchResultsContentState extends State<SearchResultsContent> {
  @override
  Widget build(BuildContext context) {
    List<CustomCard> filteredItems = filterItems(widget.misItems, widget.query);
    // print(misItems[0].title);
    print(widget.query);

    return Container(
      width: 500,
      child: ListView(
        // children: itemsResult,
        children: filteredItems,

        scrollDirection: Axis.vertical,
      ),
    );
  }

  List<CustomCard> filterItems(List<CustomCard> items, String query) {
    //print("Entrada a al fucnion");
<<<<<<< HEAD
=======
    if (query == "") {
      return items;
    }

>>>>>>> Pruebas
    setState(() {
      items
          .where(
              (item) => item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    return items
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
