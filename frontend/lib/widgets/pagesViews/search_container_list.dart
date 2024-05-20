import 'package:flutter/material.dart';
import 'package:frontend/widgets/card.dart';

class SearchResults extends StatelessWidget {
  // List<CustomCard> itemsResult;
  // SearchResults({super.key, required this.itemsResult});
  const SearchResults({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      // children: itemsResult,
      children: [
        Container(
          height: 100,
          width: 120,
        )
      ],
      scrollDirection: Axis.vertical,
    );
  }
}
