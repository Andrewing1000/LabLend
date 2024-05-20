import 'package:flutter/material.dart';
import '../navbar.dart';

void main() {
  final List<NavItem> items = [
    NavItem(
        iconNormal: Icons.home_outlined,
        iconSelected: Icons.home,
        onPressed: () {
          print("Opcion1");
        },
        title: "Home"),
    NavItem(
        iconNormal: Icons.search_sharp,
        iconSelected: Icons.search,
        onPressed: () {
          print("Opcion2");
        },
        title: "Search"),
    NavItem(
        iconNormal: Icons.notifications_none_outlined,
        iconSelected: Icons.notifications,
        onPressed: () {
          print("Opcion3");
        },
        title: "Notifications"),
    NavItem(
        iconNormal: Icons.person_2_outlined,
        iconSelected: Icons.person_2,
        onPressed: () {
          print("Opcion4");
        },
        title: "Profile"),
    NavItem(
        iconNormal: Icons.person_2_outlined,
        iconSelected: Icons.person_2,
        onPressed: () {
          print("Opcion4");
        },
        title: "Profile"),
  ];

  return runApp(MaterialApp(
      home: Container(
    color: Colors.orange,
    child: Column(
      children: [
        SizedBox(
          height: 40,
        ),
        VerticalNavbar(
          items: items,
          iconSize: 40,
        ),
      ],
    ),
  )));
}
