import 'package:flutter/material.dart';
import 'package:frontend/widgets/card.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CustomCard(
          title: "Matraz",
          subtitle:
              "Loren por favor, ya he dejado el alcohol kjnfsadkjnflasdjnflaskdjnflsakdjnfaskdjnflasdjknfsadlkjfnasdlkjfnasdlfkjndfsdlkfjnasd",
          onTap: (title, subtitle) {
            // Acción a realizar cuando se hace clic en la tarjeta
            print("Card tapped: $title - $subtitle");
          },
        ),
      ),
    ),
  ));
}
