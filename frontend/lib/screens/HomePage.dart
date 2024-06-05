import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/services/ScrollPhysics.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../services/SelectedItemContext.dart';
import '../widgets/card.dart';
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
                physics: CustomScrollPhysics(scrollSpeedFactor: 0),
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
      HorizontalCard(title: "Opción1"),
      HorizontalCard(title: "Opción2"),
      HorizontalCard(title: "Opción3"),
      HorizontalCard(title: "Opción4"),
      HorizontalCard(title: "Opción1"),
      HorizontalCard(title: "Opción2"),
      HorizontalCard(title: "Opción3"),
      HorizontalCard(title: "Opción4"),
    ];

    Item microscopio = Item(
      id: 2,
      nombre: 'Microscopio',
      description:
          'Un microscopio para el examen detallado de objetos pequeños.',
      link: 'http://example.com/microscopio',
      serialNumber: 'SN2345678901',
      quantity: 20,
      marca: Brand(id: 2, marca: 'CientíficaCo'),
      categories: [],
      quantityOnLoan: 2,
    );

    Item setTuboEnsayo = Item(
      id: 3,
      nombre: 'Set de Tubos de Ensayo',
      description:
          'Conjunto de tubos de ensayo para varios experimentos químicos.',
      link: 'http://example.com/set-tubos-ensayo',
      serialNumber: 'SN3456789012',
      quantity: 100,
      marca: Brand(id: 3, marca: 'EquipLab'),
      categories: [],
      quantityOnLoan: 10,
    );

    Item centrifuga = Item(
      id: 4,
      nombre: 'Centrífuga',
      description:
          'Una centrífuga para separar sustancias de diferentes densidades.',
      link: 'http://example.com/centrifuga',
      serialNumber: 'SN4567890123',
      quantity: 5,
      marca: Brand(id: 4, marca: 'SpinTech'),
      categories: [],
      quantityOnLoan: 1,
    );

    Item setVasosPrecipitados = Item(
      id: 5,
      nombre: 'Set de Vasos de Precipitados',
      description:
          'Conjunto de vasos de precipitados para mezclar y medir líquidos.',
      link: 'http://example.com/set-vasos-precipitados',
      serialNumber: 'SN5678901234',
      quantity: 50,
      marca: Brand(id: 5, marca: 'ChemTools'),
      categories: [],
      quantityOnLoan: 5,
    );

    Item mecheroBunsen = Item(
      id: 6,
      nombre: 'Mechero Bunsen',
      description:
          'Un mechero Bunsen para calentar sustancias durante experimentos.',
      link: 'http://example.com/mechero-bunsen',
      serialNumber: 'SN6789012345',
      quantity: 15,
      marca: Brand(id: 6, marca: 'HeatWave'),
      categories: [],
      quantityOnLoan: 3,
    );

    List<CustomCard> cItems = [
      CustomCard(item: microscopio),
      CustomCard(item: setTuboEnsayo),
      CustomCard(item: centrifuga),
      CustomCard(item: setVasosPrecipitados),
      CustomCard(item: mecheroBunsen),
    ];

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
