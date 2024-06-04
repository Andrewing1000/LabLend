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

class HomePage extends PageBase{
  ScrollController? scrollController;
  late HomeSections sections;
  SelectedItemContext selectedItem;
  HomePage({super.key,
    super.manager,
    super.child,
    this.scrollController,
    required this.selectedItem}):
      super(disposable: false){
    sections = HomeSections(selectedItem : selectedItem);
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

  void toTop(){
    scrollController?.animateTo(
    scrollController!.position.minScrollExtent,
    duration: const Duration(milliseconds: 400),
    curve: Curves.decelerate);
  }

  void toBottom(){
    scrollController?.animateTo(
    scrollController!.position.maxScrollExtent,
    duration: const Duration(milliseconds: 400),
    curve: Curves.decelerate);
  }
}

class HomePageState extends State<HomePage>{
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
                  builder: (BuildContext context, HomeSections value, Widget? child) {
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

class HomeSections extends ChangeNotifier{
  List<Widget> sections;
  SelectedItemContext selectedItem;
  HomeSections({this.sections = const [], required this.selectedItem}){
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

    Item item = Item(
      id: 1,
      nombre: 'El cojudo',
      description: 'This is an example item for testing purposes',
      link: 'http://example.com/example-item',
      serialNumber: 'SN1234567890',
      quantity: 50,
      marca: Brand(id: 1, marca: "tabaco"),
      categories: [],
      quantityOnLoan: 1,
    );


    List<CustomCard> cItems = [
      CustomCard(
        item: item,
      ),
      CustomCard(
          item: item,
      ),
      CustomCard(
        item: item,
      ),
      CustomCard(
        item: item,
      ),
      CustomCard(
        item: item,
      ),
      CustomCard(
        item: item,
      ),
      CustomCard(
        item: item,
      ),
      CustomCard(
        item: item,
      ),
      CustomCard(
        item: item,
      ),
      CustomCard(
        item: item,
      ),
      CustomCard(
        item: item,
      ),
      CustomCard(
        item: item,
      ),
    ];

    List<Widget> body = [
      HorizontalCardSection(
        items: hcItems,
      ), // Sección nueva
      CardSection(items: cItems),
      CardSection(items: cItems),
    ];

    set(body);
  }
  
  void set(List<Widget> sections){
    this.sections = sections;
    notifyListeners();
  }
  
  void add(Widget section){
    sections.add(section);
    notifyListeners();
  }
  
  void remove(Widget section){
    sections.remove(section);
    notifyListeners();
  }
}