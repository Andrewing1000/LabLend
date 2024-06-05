import 'package:flutter/material.dart';
import 'horizontal_card.dart';

class HorizontalCardSection extends StatelessWidget {
  static double spacing = 10;
  static double maxHeight = 2*(HorizontalCard.maxHeight + spacing);

  List<HorizontalCard> items;
  HorizontalCardSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 4;
          double height = maxHeight;

          if(constraints.maxWidth < 4*( HorizontalCard.minWidth+spacing)){
            crossAxisCount = 2;
            maxHeight = 4*(HorizontalCard.minHeight + spacing);
          }

          return SizedBox(

            width: double.infinity,
            height: height,
            child: GridView.builder(
              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: 4,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return items[index];
              },
            ),
          );
        },
      ),
    );
  }
}
