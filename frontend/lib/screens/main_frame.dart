import "dart:ui";


import "package:flutter/material.dart";
import "package:frontend/screens/create_item_screen.dart";
import "package:frontend/screens/create_user.dart";
import 'package:provider/provider.dart';

import "package:frontend/models/Session.dart";
import "package:frontend/screens/HomePage.dart";
import "package:frontend/services/ContextMessageService.dart";
import "package:frontend/widgets/navbar.dart";
import "package:frontend/widgets/resizable_panel.dart";

import "../services/PageManager.dart";



import "LoginPage.dart";
import "PageContainer.dart";
import "SearchItemPage.dart";
import "SearchLoanPage.dart";
import "SearchUserPage.dart";

class MainFrame extends StatefulWidget {
  ContextMessageService messageService;
  MainFrame({super.key, required this.messageService});

  @override
  State<MainFrame> createState() {
    return MainFrameState();
  }
}

class MainFrameState extends State<MainFrame> {
  double maxWidth = double.infinity;
  double maxHeight = double.infinity;

  bool onFrontier1 = false;
  bool onFrontier2 = false;
  bool grabbing1 = false;
  bool grabbing2 = false;
  ResizeController sizeLeft = ResizeController();
  ResizeController sizeRight = ResizeController();

  bool onLogin = false;
  bool onPasswordReset = false;

  late PageContainer pageContainer;
  HomePage homePage = HomePage();
  SearchItemPage searchPage = SearchItemPage();
  SearchUserPage searchUserPage = SearchUserPage();
  SearchLoanPage searchLoanPage = SearchLoanPage();
  CreateItemScreen createItemPage = CreateItemScreen();
  CreateUserScreen createUserPage = CreateUserScreen();

  Widget sidePanel = Container(); /// Implementar
  late PageManager pageManager;
  late VerticalNavbar navBar;


  MainFrameState() {
    pageManager = PageManager(defaultPage: homePage);
    pageContainer = PageContainer(
        manager: pageManager,
        onLogin: (){
          setState(() {onLogin = true;});
        });
    final List<NavItem> items = [
      NavItem(
          iconNormal: Icons.home_outlined,
          iconSelected: Icons.home,
          onPressed: () {
            pageManager.setPage(homePage);
          },
          title: "Home"),
      NavItem(
          iconNormal: Icons.search_sharp,
          iconSelected: Icons.search,
          onPressed: () {
            pageManager.setPage(searchPage);
          },
          title: "Search"),

      NavItem(
          iconNormal: Icons.view_agenda_outlined,
          iconSelected: Icons.view_agenda,
          onPressed: () {
            pageManager.setPage(searchUserPage);
          },
          title: "Search"),
      NavItem(
          iconNormal: Icons.history_toggle_off_outlined,
          iconSelected: Icons.history,
          onPressed: () {
            pageManager.setPage(searchLoanPage);
          },
          title: "Search"),
      NavItem(
          iconNormal: Icons.info_outline,
          iconSelected: Icons.info,
          onPressed: () {

          },
          title: "Search"),

      NavItem(
          iconNormal: Icons.people_outline,
          iconSelected: Icons.people,
          onPressed: (){
            pageManager.setPage(createUserPage);
          },
          title: "Create User"),

      NavItem(
          iconNormal: Icons.add_circle_outline_outlined,
          iconSelected: Icons.add_circle,
          onPressed: (){
            pageManager.setPage(createItemPage);
          },
          title: "Create User"),
    ];

    navBar = VerticalNavbar(iconSize: 30, items: items);
  }

  void performResize(double dx) {
    if (grabbing1) {
      sizeLeft.widthUpdate(delta: dx);
      return;
    }

    if (grabbing2) {
      sizeRight.widthUpdate(delta: -dx);
      return;
    }
  }

  void endResize() {
    setState(() {
      grabbing1 = false;
      grabbing2 = false;
      sizeLeft.commitUpdate();
      sizeRight.commitUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      maxWidth = constraints.maxWidth;
      maxHeight = constraints.maxHeight;

      return GestureDetector(
        onPanStart: (event) {
          if (onFrontier1) {
            setState(() {
              grabbing1 = true;
            });

            return;
          }

          if (onFrontier2) {
            setState(() {
              grabbing2 = true;
            });
            return;
          }
        },
        onPanUpdate: (event) {
          performResize(event.delta.dx);
        },
        onPanEnd: (event) {
          endResize();
        },
        onPanCancel: () {
          setState(() {
            grabbing1 = false;
            grabbing2 = false;
          });
        },
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ResizablePanel(
                      stops: [ResizeRange(start: 70, end: double.infinity)],
                      controller: sizeLeft,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: navBar,
                      )),
                  MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    onEnter: (event) {
                      setState(() {
                        onFrontier1 = true;
                      });
                    },
                    onExit: (event) {
                      setState(() {
                        onFrontier1 = false;
                      });
                    },
                    child: Container(
                      height: double.infinity,
                      width: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: grabbing1
                            ? Colors.white.withAlpha(70)
                            : onFrontier1
                                ? Colors.white.withAlpha(40)
                                : Colors.transparent,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ResizablePanel(
                      //controller: sizeRight,
                      stops: [ResizeRange(start: 0, end: double.infinity)],
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(21, 21, 21, 1.0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: pageContainer,
                      )
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    onEnter: (event) {
                      setState(() {
                        onFrontier2 = true;
                      });
                    },
                    onExit: (event) {
                      setState(() {
                        onFrontier2 = false;
                      });
                    },
                    child: Container(
                      height: double.infinity,
                      width: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: grabbing2
                            ? Colors.white.withAlpha(70)
                            : onFrontier2
                                ? Colors.white.withAlpha(40)
                                : Colors.transparent,
                      ),
                    ),
                  ),
                  ResizablePanel(
                      controller: sizeRight,
                      stops: [
                        ResizeRange(start: 100, end: 200),
                        ResizeRange.point(300.0),
                        ResizeRange.point(400.0),
                        ResizeRange(start: 400.0, end: 600.0)
                        //ResizeRange(start: 700, end: double.infinity),
                      ],
                      child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(21, 21, 21, 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: sidePanel)
                  ),
                ],
              ),
            ),
            if (onLogin || onPasswordReset)
              GestureDetector(
                onTapDown: (e) {
                  setState(() {
                    onLogin = false;
                    onPasswordReset = false;
                  });
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: onLogin
                        ? Colors.black.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                ),
              ),
            if (onLogin) LoginScreen(
              onSubmit: (email, password){
                SessionManager().login(email, password);
              },
              onPasswordReset: (){
                setState(() {
                  onPasswordReset = true;
                });
              },
            ),

            MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: widget.messageService),
              ],
              child: Consumer<ContextMessageService>(
                builder: (context, messageService, child){
                  final messageView = messageService.notification;
                  if(messageView != null && messageService.displaying){
                    return messageView;
                  }
                  return Container();
                },
              ),
            )
          ],
        ),
      );
    });
  }
}
