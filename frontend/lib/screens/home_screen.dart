import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/card.dart';
import 'package:frontend/widgets/card_section.dart';
import 'package:frontend/widgets/horizontal_card.dart';
import '../widgets/horizontal_section.dart';
import '../widgets/notification.dart';
import '../widgets/pagesViews/footer_page.dart';
import 'PageBase.dart';

class HomeScreen extends PageBase{
  final ScrollController scrollController;

  HomeScreen({super.key, required this.scrollController, required super.manager});

  @override
  _HomeScreenState createState() => _HomeScreenState();

  @override
  PageBase onDispose() {
    return this;
  }

  @override
  PageBase onSet() {
    return this;
  }
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
    return Container();
  }
}
