import 'package:flutter/material.dart';

class CustomCardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850], // Fondo gris oscuro para contrastar con el fondo negro
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: SizedBox(
        height: 300,
        width: 240,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: 240,
              height: 120,
              child: Container(
                color: Colors.grey,
              ),
            ),
            const SizedBox(
              width: 10,
              height: 30,
            ),
            const Text(
              "Titulo",
              style: TextStyle(fontSize: 24, color: Colors.white), // Texto blanco para mejor contraste
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Informacion Instrumento lorem ipsum me ca welsdj liadln lin ta bev",
                style: TextStyle(fontSize: 14, color: Colors.white70), // Texto gris claro
              ),
            )
          ],
        ),
      ),
    );
  }
}


class CustomHorizontalCardWidget extends StatelessWidget {
  const CustomHorizontalCardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850], // Fondo gris oscuro para contrastar con el fondo negro
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: 80,
        width: 240,
        child: Row(
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: Container(
                color: Colors.grey,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Titulo",
                      style: TextStyle(color: Colors.white), // Texto blanco para mejor contraste
                    ),
                  ),
                ),
                Container(
                  width: 160,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "Informacion del para fisica ",
                      style: TextStyle(color: Colors.white70), // Texto gris claro
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
