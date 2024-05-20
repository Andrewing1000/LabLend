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
<<<<<<< HEAD
  bool _showNotification =
      false; // Estado para controlar la visibilidad de la notificación
  String _notificationMessage =
      ''; // Estado para almacenar el mensaje de la notificación

=======
>>>>>>> 65b33c8a1bb0d1c83e22d15a7ecea259d5df7de1
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
<<<<<<< HEAD
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

  // Método para alternar la visibilidad de la notificación y establecer el mensaje
  void _toggleNotification(String message) {
    setState(() {
      _notificationMessage =
          message; // Establecer el mensaje de la notificación
      _showNotification = true; // Mostrar la notificación
    });

    // Ocultar la notificación automáticamente después de 3 segundos
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showNotification = false; // Ocultar la notificación
      });
    });
  }

=======
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

>>>>>>> 65b33c8a1bb0d1c83e22d15a7ecea259d5df7de1
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            Row(
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
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Botón de acción con icono de "+"
                              AccionBoton(
                                onNotification: _toggleNotification,
                                message: "¡agregado!",
                                icon: Icons.add,
                              ),
                              SizedBox(width: 20),
                              // Botón de acción con icono de "-"
                              AccionBoton(
                                onNotification: _toggleNotification,
                                message: "¡eliminado!",
                                icon: Icons.remove,
                              ),
                            ],
                          ),
                        ),
                        HorizontalCardSection(
                          items: hcItems,
                        ), // Sección nueva
                        CardSection(items: cItems),
                        CardSection(items: cItems),
                        CardSection(items: cItems),
                        CardSection(items: cItems),
                        CardSection(items: cItems),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Mostrar la notificación si _showNotification es verdadero
            if (_showNotification)
              NotificationWidget(
                message: _notificationMessage,
=======
              VerticalNavbar(
                items: items,
                iconSize: 40,
>>>>>>> 65b33c8a1bb0d1c83e22d15a7ecea259d5df7de1
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
