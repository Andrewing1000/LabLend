import 'package:flutter/material.dart';
import 'package:frontend/widgets/card.dart';
import 'package:frontend/widgets/card_section.dart';
import 'package:frontend/widgets/horizontal_card.dart';
import '../widgets/navbar.dart';
import '../widgets/horizontal_section.dart'; // Asegúrate de que los widgets de tarjetas están aquí


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<NavItem> items = [

    NavItem(
        iconNormal: Icons.home_outlined,
        iconSelected: Icons.home,
        onPressed: (){
          print("Opcion1");
        },
        title: "Home"),

    NavItem(
        iconNormal : Icons.search_sharp,
        iconSelected: Icons.search,
        onPressed: (){
          print("Opcion2");
        },
        title: "Search"),

    NavItem(
        iconNormal : Icons.notifications_none_outlined,
        iconSelected: Icons.notifications,
        onPressed: (){
          print("Opcion3");
        },
        title: "Notifications"),

    NavItem(
        iconNormal : Icons.person_2_outlined,
        iconSelected: Icons.person_2,
        onPressed: (){
          print("Opcion4");
        },
        title: "Profile"),
  ];

  List<HorizontalCard> hcItems = [
    HorizontalCard(title: "Opcion1"),
    HorizontalCard(title: "Opcion2"),
    HorizontalCard(title: "Opcion3"),
    HorizontalCard(title: "Opcion4"),
    HorizontalCard(title: "Opcion1"),
    HorizontalCard(title: "Opcion2"),
    HorizontalCard(title: "Opcion3"),
    HorizontalCard(title: "Opcion4"),
  ];


  List<CustomCard> cItems = [
    CustomCard(title: "Opcion1", subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',),
    CustomCard(title: "Opcion1", subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',),
    CustomCard(title: "Opcion1", subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',),
    CustomCard(title: "Opcion1", subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',),
    CustomCard(title: "Opcion1", subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',),
    CustomCard(title: "Opcion1", subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',),
    CustomCard(title: "Opcion1", subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',),
    CustomCard(title: "Opcion1", subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',),
    CustomCard(title: "Opcion1", subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',),
    CustomCard(title: "Opcion1", subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Row(
          children: [
              VerticalNavbar(
                items: items,
                iconSize: 40,
              ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    HorizontalCardSection(items: hcItems,), // Sección nueva
                    CardSection(items : cItems),
                    CardSection(items : cItems),
                    CardSection(items : cItems),
                    CardSection(items : cItems),
                    CardSection(items : cItems),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
