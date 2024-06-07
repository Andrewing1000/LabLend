import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/ScrollPhysics.dart';
import 'package:provider/provider.dart';
import '../models/Session.dart';
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
  List<Widget> sections = [];
  SelectedItemContext selectedItem;

  HomeSections({required this.selectedItem}) {
    _initializeSections();
  }

  Future<void> _initializeSections() async {
    List<Item> items = await SessionManager.inventory.getItems();
    items.shuffle();

    List<CardVista> randomItems = items.take(3).map((item) {
      return CardVista(
        item: item,
        imagePath:
            'assets/images/${item.nombre.toLowerCase().replaceAll(' ', '_')}.jpg',
      );
    }).toList();

    List<Widget> body = [
      HorizontalCardSection(
          items: []), // Este se puede completar según sea necesario
      CardSection(items: randomItems),
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
