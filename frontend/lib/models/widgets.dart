import 'package:flutter/material.dart';

class CustomCardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
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
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Informacion Instrumento lorem ipsum me ca welsdj liadln lin ta bev",
                style: TextStyle(fontSize: 14, color: Colors.black54),
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
      //color: Color(Theme.of(context).cardColor.blue),
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
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                Container(
                  width: 160,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text("Informacion del para fisica "),
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

