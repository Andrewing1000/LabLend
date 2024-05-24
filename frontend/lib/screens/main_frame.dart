import "dart:ui";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:frontend/screens/home_screen.dart";
import "package:frontend/screens/previews/login_recuperado_test.dart";
import "package:frontend/screens/previews/login_test.dart";
import "package:frontend/widgets/navbar.dart";
import "package:frontend/widgets/pagesViews/welcome_page.dart";
import "package:frontend/widgets/resizable_panel.dart";

import "../widgets/pagesViews/search_page.dart";
import "../widgets/tool_bar.dart";

import "../widgets/notification.dart";

class MainFrame extends StatefulWidget {
  static GlobalKey<VerticalNavbarState> vNavBarKey = GlobalKey();
  MainFrame({super.key});

  @override
  State<MainFrame> createState() {
    return MainFrameState();
  }
}

class MainFrameState extends State<MainFrame> {
  bool onFrontier1 = false;
  bool onFrontier2 = false;
  bool grabbing1 = false;
  bool grabbing2 = false;

  double maxWidth = double.infinity;
  double maxHeight = double.infinity;

  ResizeController sizeLeft = ResizeController();
  ResizeController sizeRight = ResizeController();
  VerticalNavbar navBar;

  ScrollController homeScrollController = ScrollController();

  bool onLogin = false;

  Widget loginPage = LoginScreen(
    onSubmit: () {
      NotificationWidget(
        message: "Login Exitoso",
      );
    },
  );
  Widget passResetPage = RecuperarContrasenaScreen();
  Widget welcomePage = const WelcomePage();
  Widget? homePage;
  Widget? searchPage;
  Widget page = HomeScreen(scrollController: ScrollController());
  Widget? sidePanel;

  MainFrameState()
      : navBar = VerticalNavbar(
          key: MainFrame.vNavBarKey,
          iconSize: 30,
          items: const [],
        ),
        super() {
    homePage = HomeScreen(scrollController: homeScrollController);
    searchPage = SearchPage(query: "");
    page = homePage!;

    final List<NavItem> items = [
      NavItem(
          iconNormal: Icons.home_outlined,
          iconSelected: Icons.home,
          onPressed: () {
            switchPage(this.homePage);
            setState(() {
              homeScrollController.animateTo(
                  homeScrollController.position.minScrollExtent,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeIn);
            });
          },
          title: "Home"),
      NavItem(
          iconNormal: Icons.search_sharp,
          iconSelected: Icons.search,
          onPressed: () {
            switchPage(this.searchPage);
          },
          title: "Search"),
      NavItem(
          iconNormal: Icons.info_outline,
          iconSelected: Icons.info,
          onPressed: () {
            switchPage(this.homePage);
            setState(() {
              homeScrollController.animateTo(
                  homeScrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeIn);
            });
          },
          title: "Search"),
    ];

    navBar =
        VerticalNavbar(key: MainFrame.vNavBarKey, iconSize: 30, items: items);
  }

  void switchPage(Widget? page) {
    if (page == null) {
      return;
    }

    setState(() {
      this.page = page;
    });
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
                          child: Stack(
                            children: [
                              page,
                              ToolBar(
                                onConsult: (e) {
                                  setState(
                                    () {
                                      searchPage = SearchPage(query: e);
                                      page = searchPage!;
                                    },
                                  );
                                },
                                onLogin: () {
                                  setState(() {
                                    onLogin = true;
                                  });
                                },
                              ),
                            ],
                          ),
                        )),
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
                        ResizeRange.point(300),
                        ResizeRange.point(400),
                        ResizeRange(start: 400, end: 600)
                        //ResizeRange(start: 700, end: double.infinity),
                      ],
                      child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(21, 21, 21, 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: sidePanel)),
                ],
              ),
            ),
            if (onLogin)
              GestureDetector(
                onTapDown: (e) {
                  setState(() {
                    onLogin = false;
                  });
                },
                child: Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      color: onLogin
                          ? Colors.black.withOpacity(0.2)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            if (onLogin) loginPage,
          ],
        ),
      );
    });
  }
}
