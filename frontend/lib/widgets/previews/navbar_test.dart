// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import '../../models/User.dart';
import '../navbar.dart';


void main(){


  final List<Role> permissions = [Role.adminRole, Role.assistantRole, Role.visitorRole];

  final List<NavItem> items = [
    NavItem(
        iconNormal: Icons.home_outlined,
        iconSelected: Icons.home,
        onPressed: () {
          print("Opcion1");
        },
        title: "Home",
        permissions : permissions,),

    NavItem(
        iconNormal: Icons.search_sharp,
        iconSelected: Icons.search,
        onPressed: () {
          print("Opcion2");
        },
      title: "Search",
      permissions : permissions,
    ),

    NavItem(
        iconNormal: Icons.notifications_none_outlined,
        iconSelected: Icons.notifications,
        onPressed: () {
          print("Opcion3");
        },
      title: "Notifications",
      permissions : permissions,
    ),

    NavItem(
        iconNormal: Icons.person_2_outlined,
        iconSelected: Icons.person_2,
        onPressed: () {
          print("Opcion4");
        },
      title: "Profile",
      permissions : permissions,
    ),
    
    NavItem(
        iconNormal: Icons.person_2_outlined,
        iconSelected: Icons.abc,
        onPressed: () {
          print("hola");
        },
      title: "Profile",
      permissions : permissions,
    ),
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
