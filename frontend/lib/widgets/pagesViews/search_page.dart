import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:frontend/widgets/barra_buesqueda.dart';
import 'package:frontend/widgets/barra_buesqueda.dart';
=======
>>>>>>> Pruebas
import 'package:frontend/widgets/card.dart';
import 'package:frontend/widgets/pagesViews/mi_barra_busqueda.dart';
import 'package:frontend/widgets/pagesViews/search_container_list.dart';

<<<<<<< HEAD
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
=======
import '../barra_busqueda.dart';

class SearchPage extends StatefulWidget {
  String query;

  SearchPage({super.key, required this.query});
>>>>>>> Pruebas

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  InputFillResponse input = InputFillResponse();
<<<<<<< HEAD
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
=======

  List<CustomCard> cItems = [
    CustomCard(
      title: "Maquina 1",
      subtitle: 'Maquina',
    ),
    CustomCard(
      title: "Pizarra",
      subtitle: 'Pizarra',
    ),
    CustomCard(
      title: "Marraqueta",
      subtitle: 'Pizarra',
    ),
    CustomCard(
      title: "Proveta",
      subtitle: 'Maquina 2',
    ),
    CustomCard(
      title: "Maquina 1",
      subtitle: 'Maquina',
    ),
    CustomCard(
      title: "Pantera",
      subtitle: 'Pizarra',
    ),
    CustomCard(
      title: "Carnaval",
      subtitle: 'Pizarra',
    ),
    CustomCard(
      title: "MAquina 2",
      subtitle: 'Maquina 2',
    ),
    CustomCard(
      title: "Maquina 1",
      subtitle: 'Maquina',
    ),
    CustomCard(
      title: "Pizarra",
      subtitle: 'Pizarra',
    ),
    CustomCard(
      title: "Marron",
      subtitle: 'Pizarra',
    ),
    CustomCard(
      title: "MAquina 2",
      subtitle: 'Maquina 2',
>>>>>>> Pruebas
    ),
  ];

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
=======
    String busqueda;
>>>>>>> Pruebas
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
<<<<<<< HEAD
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
=======
                // Text(
                Container(
                  height: 110,
                ),

                Expanded(
                  child: SearchResultsContent(
                    misItems: cItems,
                    query: widget.query,
>>>>>>> Pruebas
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
