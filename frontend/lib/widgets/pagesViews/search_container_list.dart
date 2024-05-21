import 'package:flutter/material.dart';
import 'package:frontend/widgets/card.dart';

class SearchResultsContent extends StatelessWidget {
  List<CustomCard> misItems;

  // SearchResults({super.key, required this.itemsResult});
  SearchResultsContent({super.key, this.misItems = const []});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      child: ListView(
        // children: itemsResult,
        children: misItems,
        scrollDirection: Axis.vertical,
      ),
    );
  }
}
