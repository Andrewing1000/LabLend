import 'package:flutter/material.dart';

class CustomCard extends StatefulWidget {
  static double width = 200;
  static double height = (9.5 / 7) * width;

  final String title;
  final String subtitle;
  final Function(String, String) onTap; // Añadimos el callback

  CustomCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap, // Añadimos el callback
  }) : super(key: key);

  @override
  State<CustomCard> createState() {
    return CustomCardState();
  }
}

class CustomCardState extends State<CustomCard> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () =>
            widget.onTap(widget.title, widget.subtitle), // Llamamos al callback
        child: SizedBox(
          width: CustomCard.width,
          height: CustomCard.height,
          child: Card(
            color: const Color.fromRGBO(21, 21, 21, 1.0),
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    height: CustomCard.height * 5.8 / 9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        "/assets/images/place_holder.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: "/assets/fonts/Metropolis-Black.ttf",
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.7),
                      fontFamily: "/assets/fonts/Metropolis-Black.ttf",
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
