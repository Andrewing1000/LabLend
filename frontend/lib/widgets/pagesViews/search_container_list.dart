import 'package:flutter/material.dart';
import 'package:frontend/widgets/card.dart';

class SearchResultsContent extends StatelessWidget {
  List<CustomCard> misItems = [];

  

  // SearchResults({super.key, required this.itemsResult});
  SearchResultsContent(List<CustomCard> misItems, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 900,
      height: 900,
      child: ListView(
        // children: itemsResult,
        children: misItems,
        scrollDirection: Axis.vertical,
      ),
    );
  }
}
