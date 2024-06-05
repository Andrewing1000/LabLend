import 'package:flutter/material.dart';
import 'package:frontend/services/ScrollPhysics.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../services/SelectedItemContext.dart';
import '../widgets/card_vista.dart';
import '../widgets/card_section.dart';
import '../widgets/horizontal_card.dart';
import '../widgets/horizontal_section.dart';
import 'PageBase.dart';

class HomePage extends PageBase {
  ScrollController? scrollController;
  late HomeSections sections;
  SelectedItemContext selectedItem;

  HomePage(
      {super.key,
      super.manager,
      super.child,
      this.scrollController,
      required this.selectedItem})
      : super(disposable: false) {
    sections = HomeSections(selectedItem: selectedItem);
    scrollController ??= ScrollController();
  }

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }

  @override
  void onDispose() async {
    return;
  }

  @override
  void onSet() {
    return;
  }

  void toTop() {
    scrollController?.animateTo(scrollController!.position.minScrollExtent,
        duration: const Duration(milliseconds: 400), curve: Curves.decelerate);
  }

  void toBottom() {
    scrollController?.animateTo(scrollController!.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400), curve: Curves.decelerate);
  }
}

class HomePageState extends State<HomePage> {
  List<Widget> sectionList = [];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeSections>.value(value: widget.sections),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const CustomScrollPhysics(scrollSpeedFactor: 0),
                controller: widget.scrollController,
                child: Consumer<HomeSections>(
                  builder: (BuildContext context, HomeSections value,
                      Widget? child) {
                    return Column(
                      children: value.sections,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeSections extends ChangeNotifier {
  List<Widget> sections;
  SelectedItemContext selectedItem;

  HomeSections({this.sections = const [], required this.selectedItem}) {
    List<HorizontalCard> hcItems = [
      const HorizontalCard(title: "Opción 1"),
      const HorizontalCard(title: "Opción 2"),
      const HorizontalCard(title: "Opción 3"),
      const HorizontalCard(title: "Opción 4"),
      const HorizontalCard(title: "Opción 1"),
      const HorizontalCard(title: "Opción 2"),
      const HorizontalCard(title: "Opción 3"),
      const HorizontalCard(title: "Opción 4"),
    ];

    List<Item> items = [
      Item(
        id: 1,
        nombre: 'Microscopio',
        description: 'Microscopio de alta precisión para observación celular.',
        link: 'http://example.com/microscopio',
        serialNumber: 'SN1234567890',
        quantity: 50,
        marca: Brand(id: 1, marca: "OptiLab"),
        categories: [],
        quantityOnLoan: 1,
      ),
      Item(
        id: 2,
        nombre: 'Centrifuga',
        description: 'Centrífuga para separación de muestras biológicas.',
        link: 'http://example.com/centrifuga',
        serialNumber: 'SN0987654321',
        quantity: 20,
        marca: Brand(id: 2, marca: "BioSpin"),
        categories: [],
        quantityOnLoan: 2,
      ),
      Item(
        id: 3,
        nombre: 'Espectro',
        description: 'Espectrofotómetro para análisis de absorbancia.',
        link: 'http://example.com/espectrofotometro',
        serialNumber: 'SN1122334455',
        quantity: 10,
        marca: Brand(id: 3, marca: "SpectroTech"),
        categories: [],
        quantityOnLoan: 0,
      ),
      Item(
        id: 4,
        nombre: 'Balanza Analitica',
        description: 'Balanza analítica de alta precisión.',
        link: 'http://example.com/balanza',
        serialNumber: 'SN2233445566',
        quantity: 15,
        marca: Brand(id: 4, marca: "WeighPro"),
        categories: [],
        quantityOnLoan: 1,
      ),
      Item(
        id: 5,
        nombre: 'Protoboard',
        description:
            'Protoboard para la conexion de clabes o diferentes elementos.',
        link: 'http://example.com/balanza',
        serialNumber: 'SN2233445566',
        quantity: 15,
        marca: Brand(id: 4, marca: "WeighPro"),
        categories: [],
        quantityOnLoan: 1,
      ),
      Item(
        id: 5,
        nombre: 'Cables',
        description: 'Cables con diferentes usos.',
        link: 'http://example.com/balanza',
        serialNumber: 'SN2233445566',
        quantity: 15,
        marca: Brand(id: 4, marca: "WeighPro"),
        categories: [],
        quantityOnLoan: 1,
      ),
      Item(
        id: 6,
        nombre: 'Caja centrifuga',
        description: 'Para ver el comportamiento centrifugo.',
        link: 'http://example.com/balanza',
        serialNumber: 'SN2233445566',
        quantity: 15,
        marca: Brand(id: 4, marca: "WeighPro"),
        categories: [],
        quantityOnLoan: 1,
      ),
      Item(
        id: 7,
        nombre: 'Motor Paso a Paso',
        description: 'realizacion de circuitos.',
        link: 'http://example.com/balanza',
        serialNumber: 'SN2233445566',
        quantity: 15,
        marca: Brand(id: 4, marca: "WeighPro"),
        categories: [],
        quantityOnLoan: 1,
      ),
    ];

    List<CardVista> cItems = items
        .map((item) => CardVista(
              item: item,
              imagePath:
                  'assets/images/${item.nombre.toLowerCase().replaceAll(' ', '_')}.jpg',
            ))
        .toList();

    List<Widget> body = [
      HorizontalCardSection(items: hcItems),
      CardSection(items: cItems),
    ];

    set(body);
  }

  void set(List<Widget> sections) {
    this.sections = sections;
    notifyListeners();
  }

  void add(Widget section) {
    sections.add(section);
    notifyListeners();
  }

  void remove(Widget section) {
    sections.remove(section);
    notifyListeners();
  }
}
