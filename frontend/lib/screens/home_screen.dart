import 'package:flutter/material.dart';
import 'package:frontend/widgets/card.dart';
import 'package:frontend/widgets/card_section.dart';
import 'package:frontend/widgets/horizontal_card.dart';
import '../widgets/horizontal_section.dart';
import '../widgets/notification.dart';
import '../widgets/pagesViews/footer_page.dart';

class HomeScreen extends StatefulWidget {
  final ScrollController scrollController;

  HomeScreen({super.key, required this.scrollController});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showNotification = false;
  String _notificationMessage = '';

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
    ),
  ];

  void _toggleNotification(String message) {
    setState(() {
      _notificationMessage = message;
      _showNotification = true;
    });

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showNotification = false;
      });
    });
  }

  void _onSearch(String query) {
    print("Buscando: $query");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  HorizontalCardSection(
                    items: hcItems,
                  ), // Sección nueva
                  CardSection(items: cItems),
                  CardSection(items: cItems),
                  const Footer(),
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
