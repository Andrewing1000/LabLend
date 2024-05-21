import 'package:flutter/material.dart';
import 'package:frontend/widgets/barra_buesqueda.dart';
//import 'package:frontend/widgets/barra_buesqueda.dart';
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

  List<CustomCard> cItems = [
    CustomCard(
      title: "Opcion1",
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',
    ),
    CustomCard(
      title: "Opcion1",
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',
    ),
    CustomCard(
      title: "Opcion1",
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',
    ),
    CustomCard(
      title: "Opcion1",
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf',
    ),
    CustomCard(
      title: "Opcion1",
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnflksflk sdjnflksdjf',
    ),
    CustomCard(
      title: "Opcion1",
      subtitle:
          'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf lksflk sdjnflksdjf',
    ),
    CustomCard(
      title: "Opcion1",
      subtitle:
          'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf lksflk sdjnflksdjf',
    ),
    CustomCard(
      title: "Opcion1",
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
                // Text(
                //   "Coso de Navegacion",
                //   style: TextStyle(color: Colors.white, fontSize: 45),
                // ),
                BarraBusqueda(
                  onSearch: (p0) => print(p0),
                  onChange: (value) {
                    setState(() {
                      input.input = value;
                      print(input.input);
                    });
                  },
                ),
                // MyBarraBusqueda(
                //   hintText: 'Buscar...',
                //   onChanged: (value) {
                //     print('Texto de búsqueda: $value');
                //   },
                // ),
                // Text(
                //   "Contenedor con la lista de los objetos",
                //   style: TextStyle(color: Colors.white, fontSize: 45),
                // )
                Expanded(
                    child: SearchResultsContent(misItems: cItems),
                ),

              ],
            ),
          ),
        )
      ],
    );
  }
}
