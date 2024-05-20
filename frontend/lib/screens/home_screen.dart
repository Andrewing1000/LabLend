import 'package:flutter/material.dart';
import 'package:frontend/widgets/card.dart';
import 'package:frontend/widgets/card_section.dart';
import 'package:frontend/widgets/horizontal_card.dart';
import '../widgets/navbar.dart';
import '../widgets/horizontal_section.dart';
import '../widgets/tool_bar.dart'; // Asegúrate de que los widgets de tarjetas están aquí


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
        iconNormal : Icons.info_outline,
        iconSelected: Icons.info,
        onPressed: (){
          print("Opcion2");
        },
        title: "Search"),

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
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              VerticalNavbar(
                items: items,
                iconSize: 40,
              ),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(21, 21, 21, 1.0),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    ToolBar(),

                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      height: 550,
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



                  ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
