// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:frontend/models/User.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/widgets/DropDownFilter.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/PageManager.dart';
import 'package:frontend/widgets/barra_busqueda.dart';
import 'package:frontend/widgets/cicular_button.dart';

import '../models/Session.dart';

class ToolBar extends StatefulWidget{
  static double height = 130;
  PageManager manager;
  Function onLogin;
  ToolBar({
    super.key,
    required this.manager,
    required this.onLogin,
  });

  @override
  State<ToolBar> createState() {
    return ToolBarState();
  }
}

class ToolBarState extends State<ToolBar> {
  // String de opcion seleccionada
  String? _selectedOption;
  // LIsta de Prueba
  final List<String> _options = [
    'Option 1',
    'Option 2',
    'Option 3',
    'Option 4'
  ];

  TextEditingController searchBarController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        // color: Color.fromARGB(255, 10, 224, 99),
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(10, 224, 99, 1),
            Color.fromARGB(255, 10, 150, 150),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<PageManager>.value(value: widget.manager),
        ],
        child: Consumer<PageManager>(
            builder: (context, manager, child) {
              var page = manager.currentPage;
              if(manager.currentPage is BrowsablePage){
                page = page as BrowsablePage;
              }

              var activateBar = false;
              if(page is BrowsablePage){
                activateBar = page.searchEnabled;
                searchBarController.text = page.searchField.value;
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CircularButton.static(
                        normalIcon: Icons.arrow_back_ios_new,
                        isAvailable: manager.isLastAvailable,
                        size: 25,
                        isSelected: true,
                        onPressed: (){
                          manager.toLast();
                        },
                      ),
                      Container(width: 10,),
                      CircularButton.static(
                        normalIcon: Icons.arrow_forward_ios,
                        isAvailable: manager.isNextAvailable,
                        size: 25,
                        isSelected: true,
                        onPressed: (){
                          setState(() {
                            manager.toNext();
                          });
                        },
                      ),
                      Container(width: 10,),

                      if(activateBar)
                        Expanded(
                          child: BarraBusqueda(
                              controller: searchBarController,
                              onChange: (String value){
                                if(page is BrowsablePage){
                                  page.searchField.value = value;
                                }
                              },
                              onSearch: (e){})
                        ),

                      Container(width: 10,),
                      Spacer(),

                      if(SessionManager.session.user is! VisitorUser) CircularButton.animated(
                        normalIcon: Icons.notifications_none_outlined,
                        selectedIcon: Icons.notifications,
                        size: 25,
                        isSelected: true,
                        onPressed: (){
                          setState(() {
                            throw UnimplementedError();
                            ///Implementar
                          });
                        },
                      ),

                      Container(width: 10,),
                      CircularButton.animated(
                        normalIcon: Icons.login,
                        size: 25,
                        isSelected: true,
                        onPressed: (){
                          setState(() {
                            widget.onLogin();
                          });
                        },
                      ),

                    ],
                  ),
                  Container(height: 20,),
                  if(page is BrowsablePage) Row(
                    mainAxisSize: MainAxisSize.max,
                    children: page.filters.items.map((Filter item){
                      return DropDownFilter(filter: item);
                    }).toList(),
                  )
                ],
              );
            },
          ),
      ),
    );
  }
}
