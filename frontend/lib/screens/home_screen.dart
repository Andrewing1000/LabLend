import 'package:flutter/material.dart';
import 'package:frontend/widgets/card.dart';
import 'package:frontend/widgets/card_section.dart';
import 'package:frontend/widgets/horizontal_card.dart';
import '../widgets/navbar.dart';
import '../widgets/horizontal_section.dart'; // Asegúrate de que los widgets de tarjetas están aquí
import '../widgets/accion_boton.dart'; // Importa el widget de acción del botón
import '../widgets/notification.dart'; // Importa el widget de notificación

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showNotification = false; // Estado para controlar la visibilidad de la notificación
  String _notificationMessage = ''; // Estado para almacenar el mensaje de la notificación

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
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf lksflk sdjnflksdjf',
    ),
    CustomCard(
      title: "Opcion1",
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf lksflk sdjnflksdjf',
    ),
    CustomCard(
      title: "Opcion1",
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnf lksflk sdjnflksdjf',
    ),
  ];

  // Método para alternar la visibilidad de la notificación y establecer el mensaje
  void _toggleNotification(String message) {
    setState(() {
      _notificationMessage = message; // Establecer el mensaje de la notificación
      _showNotification = true; // Mostrar la notificación
    });

    // Ocultar la notificación automáticamente después de 3 segundos
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showNotification = false; // Ocultar la notificación
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
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
                        HorizontalCardSection(items: hcItems,), // Sección nueva
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
              ),
          ],
        ),
      ),
    );
  }
}
