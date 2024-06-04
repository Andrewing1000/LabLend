import 'package:flutter/material.dart';
import 'package:frontend/widgets/card.dart';

import '../../models/item.dart';

void main() {
  Item item = Item(
    id: 1,
    nombre: 'El cojudo',
    description: 'This is an example item for testing purposes',
    link: 'http://example.com/example-item',
    serialNumber: 'SN1234567890',
    quantity: 50,
    marca: Brand(id: 1, marca: "tabaco"),
    categories: [],
    quantityOnLoan: 1,
  );
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CustomCard(
          item: item,
          onTap: (title, subtitle) {
            // Acción a realizar cuando se hace clic en la tarjeta
            print("Card tapped: $title - $subtitle");
          },
        ),
      ),
    ),
  ));
}
