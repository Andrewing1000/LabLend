import 'package:flutter/material.dart';

class HorizontalCard extends StatefulWidget {
  static const double minWidth = 200;
  static const double minHeight = (2 / 7.5) * minWidth;
  static const double maxWidth = 410;
  static const double maxHeight = (2 / 13) * maxWidth;

  final String title;

  HorizontalCard({super.key, required this.title});

  @override
  State<HorizontalCard> createState() {
    return HorizontalCardState();
  }
}

class HorizontalCardState extends State<HorizontalCard> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the width and height based on the constraints and the min/max values
        double width = constraints.maxWidth;
        if (width > HorizontalCard.maxWidth) {
          width = HorizontalCard.maxWidth;
        } else if (width < HorizontalCard.minWidth) {
          width = HorizontalCard.minWidth;
        }

        double height = (2 / 7.5) * width;
        if (height > HorizontalCard.maxHeight) {
          height = HorizontalCard.maxHeight;
        } else if (height < HorizontalCard.minHeight) {
          height = HorizontalCard.minHeight;
        }

        return Align(
          alignment: Alignment.center,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: SizedBox(
                    height: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                          "assets/images/place_holder.png",
                        fit: BoxFit.cover,
                        isAntiAlias: true,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Text(
                              widget.title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: height / 4,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
