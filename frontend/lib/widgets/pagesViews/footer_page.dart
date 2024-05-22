import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 550,
        width: 1200,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.bottomLeft,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/place_holder.png'),
                      fit: BoxFit.cover)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Text(
                  "Informacion: ",
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            Container(
              height: 550,
              width: 1200,
              alignment: Alignment.bottomRight,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Laboratorio de Fìsica",
                    style: TextStyle(fontSize: 65, color: Colors.white70)),
              ),
            )
          ],
        ));
  }
}
