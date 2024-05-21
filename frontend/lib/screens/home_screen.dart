import 'package:flutter/material.dart';
import 'package:frontend/widgets/card.dart';
import 'package:frontend/widgets/card_section.dart';
import 'package:frontend/widgets/horizontal_card.dart';
import '../widgets/navbar.dart';
import '../widgets/accion_boton.dart';
import '../widgets/horizontal_section.dart'; // Asegúrate de que los widgets de tarjetas están aquí
import '../widgets/notification.dart'; // Importa el widget de notificación
import '../widgets/barra_busqueda.dart'; // Importa el widget de barra de búsqueda

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showNotification = false; // Estado para controlar la visibilidad de la notificación
  String _notificationMessage = ''; // Estado para almacenar el mensaje de la notificación



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
      subtitle: 'dskjafnsdlkjfnlsdj dsfslakdjnflsajdnf lksflksdjnflksflk sdjnflksdjf',
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

  // Método de búsqueda (actualmente imprime el término de búsqueda en la consola)
  void _onSearch(String query) {
    print("Buscando: $query");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Stack(
          children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    SizedBox(height: 200,),
                    HorizontalCardSection(items: hcItems,), // Sección nueva
                    CardSection(items: cItems),
                    CardSection(items: cItems),
                    CardSection(items: cItems),
                    CardSection(items: cItems),
                    CardSection(items: cItems),
                  ],
                ),
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

