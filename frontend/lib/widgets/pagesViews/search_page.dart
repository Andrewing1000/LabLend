import 'package:flutter/material.dart';
import 'package:frontend/widgets/barra_buesqueda.dart';
import 'package:frontend/widgets/barra_buesqueda.dart';
import 'package:frontend/widgets/card.dart';
import 'package:frontend/widgets/pagesViews/mi_barra_busqueda.dart';
import 'package:frontend/widgets/pagesViews/search_container_list.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  InputFillResponse input = InputFillResponse();
  String busqueda = "";
  List<CustomCard> cItems = [
    CustomCard(
      title: "America",
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',
    ),
    CustomCard(
      title: "Bolivia",
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',
    ),
    CustomCard(
      title: "Centro America",
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',
    ),
    CustomCard(
      title: "Panama",
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',
    ),
    CustomCard(
      title: "Urion",
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnflksflk sdjnflksdjf',
    ),
    CustomCard(
      title: "Caligula",
      subtitle:
          'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf lksflk sdjnflksdjf',
    ),
    CustomCard(
      title: "Nation",
      subtitle:
          'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf lksflk sdjnflksdjf',
    ),
    CustomCard(
      title: "Monterey",
      subtitle:
          'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf lksflk sdjnflksdjf',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Center(
          child: Container(
            height: size.height * 0.88,
            width: size.width * 0.88,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BarraBusqueda(
                  onSearch: (p0) => print(p0),
                  onChange: (value) {
                    setState(() {
                      input.input = value;
                      busqueda = value;

                      print(busqueda);
                    });
                  },
                ),
                Expanded(
                  child: SearchResultsContent(
                    misItems: cItems,
                    query: busqueda,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
