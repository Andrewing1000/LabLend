import 'package:flutter/material.dart';
import 'package:frontend/models/User.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/widgets/DropDownFilter.dart';
import 'package:frontend/widgets/edit_item_form.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/PageManager.dart';
import 'package:frontend/widgets/barra_busqueda.dart';
import 'package:frontend/widgets/cicular_button.dart';

import '../models/Session.dart';
import 'DropdownDateFilter.dart';

class ToolBar extends StatefulWidget{
  static double height = 130;
  PageManager manager;
  Function onLogin;
  Function onLogout;
  Function onCartLookup;
  ToolBar({
    super.key,
    required this.manager,
    required this.onLogin,
    required this.onLogout,
    required this.onCartLookup,
  });

  @override
  State<ToolBar> createState(){
    return ToolBarState();
  }
}

class ToolBarState extends State<ToolBar>{


  TextEditingController searchBarController = TextEditingController();
  @override
  Widget build(BuildContext context){
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<PageManager>.value(value: widget.manager),
          ChangeNotifierProvider<SessionManager>.value(value: SessionManager(),),
        ],
        child: Consumer2<PageManager, SessionManager>(
          builder: (context, manager, sessionManager, child) {
            var page = manager.currentPage;
            if(manager.currentPage is BrowsablePage){
              page = page as BrowsablePage;
            }

            var activateBar = false;
            if(page is BrowsablePage){
              activateBar = page.searchEnabled;
              searchBarController.text = page.searchField.value;
            }

            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                      color: page is BrowsablePage?
                        const Color.fromRGBO(21, 21, 21, 1.0):
                        Colors.amberAccent,
                      ),
                      child: Column(
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
                              const Spacer(),

                              if(sessionManager.session.user is! VisitorUser) CircularButton.animated(
                                normalIcon: Icons.shopping_cart_outlined,
                                selectedIcon: Icons.shopping_cart,
                                size: 25,
                                isSelected: true,
                                onPressed: (){
                                  widget.onCartLookup();
                                },
                              ),
                              Container(width: 10,),

                              if(sessionManager.session.user is! VisitorUser) CircularButton.animated(
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
                                normalIcon: sessionManager.session.user is VisitorUser?
                                  Icons.person:
                                  Icons.logout,
                                size: 25,
                                isSelected: true,
                                onPressed: () async {
                                  if(sessionManager.session.user is VisitorUser){
                                    await widget.onLogin();
                                  }
                                  else{
                                    await widget.onLogout();
                                  }
                                },
                              ),

                            ],
                          ),
                          Container(height: 20,),
                          if(page is BrowsablePage) Row(
                            mainAxisSize: MainAxisSize.max,
                            children: page.filterSet.filters.map((Filter item){
                              return Row(
                                children: [
                                  item is DateFilter? DropdownDateFilter(filter:item): DropDownFilter(filter: item),
                                  Container(width: 30,),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    if(!sessionManager.isOnline) Container(
                      color: Colors.white,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            child: const Text("Modo offline",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Align(
                  alignment: Alignment(0.5, 0.5),
                  child: Container(
                    height: ToolBar.height/1.5,
                    child: Image.asset('/images/ucb_logo.png',
                      ),
                  ),
                )

              ],
            );
          },
        ),
    );
  }
}