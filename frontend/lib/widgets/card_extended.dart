import 'package:flutter/material.dart';

class CardExtended extends StatefulWidget {
  static const double minWidth = 600; // Ancho ajustado para más contenido
  static const double minHeight = 60;
  static const double maxWidth = 800;
  static const double maxHeight = 100;

  final String imageUrl;
  final String equipmentName;
  final String manufacturer;
  final String model;
  final String acquisitionDate;
  final String location;

  CardExtended({
    super.key,
    required this.imageUrl,
    required this.equipmentName,
    required this.manufacturer,
    required this.model,
    required this.acquisitionDate,
    required this.location,
  });

  @override
  State<CardExtended> createState() {
    return CardExtendedState();
  }
}

class CardExtendedState extends State<CardExtended> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the width and height based on the constraints and the min/max values
        double width = constraints.maxWidth;
        if (width > CardExtended.maxWidth) {
          width = CardExtended.maxWidth;
        } else if (width < CardExtended.minWidth) {
          width = CardExtended.minWidth;
        }

        double height = CardExtended.minHeight;

        return Align(
          alignment: Alignment.center,
          child: Container(
            width: width,
            constraints: BoxConstraints(
              minHeight: height,
              maxHeight: CardExtended.maxHeight,
            ),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: SizedBox(
                    height: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        isAntiAlias: true,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.equipmentName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.manufacturer,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    widget.model,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    widget.acquisitionDate,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    widget.location,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
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
