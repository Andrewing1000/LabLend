import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/previews/login_recuperado_test.dart';
import 'package:frontend/screens/previews/login_test.dart';
import 'package:frontend/widgets/pagesViews/welcome_page.dart';
import 'package:frontend/widgets/resizable_panel.dart';
import '../widgets/navbar_horizontal.dart';
import '../widgets/pagesViews/search_page.dart';
import '../widgets/tool_bar.dart';
import '../widgets/notification.dart';

class VerticalMainFrame extends StatefulWidget {
  static GlobalKey<VerticalNavbarState> vNavBarKey = GlobalKey();
  VerticalMainFrame({super.key});

  @override
  State<VerticalMainFrame> createState() {
    return MainFrameState();
  }
}

class MainFrameState extends State<VerticalMainFrame> {
  double maxWidth = double.infinity;
  double maxHeight = double.infinity;

  HorizontalNavbar navBar;

  ScrollController homeScrollController = ScrollController();

  bool onLogin = false;

  Widget loginPage = LoginScreen(
    onSubmit: () {},
  );
  Widget passResetPage = RecuperarContrasenaScreen();
  Widget welcomePage = const WelcomePage();
  Widget? homePage;
  Widget? searchPage;
  Widget page = HomeScreen(scrollController: ScrollController());
  Widget? sidePanel;

  MainFrameState()
      : navBar = HorizontalNavbar(
    key: VerticalMainFrame.vNavBarKey,
    iconSize: 50,
    items: const [],
  ),
        super() {
    homePage = HomeScreen(scrollController: homeScrollController);
    searchPage = SearchPage(query: "");
    page = homePage!;
    loginPage = LoginScreen(onSubmit: loginSuccess);

    final List<NavItem> items = [
      NavItem(
          iconNormal: Icons.home_outlined,
          iconSelected: Icons.home,
          onPressed: () {
            switchPage(homePage);
            Future.delayed(Duration(milliseconds: 100), () {
              setState(() {
                homeScrollController.animateTo(
                    homeScrollController.position.minScrollExtent,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeIn);
              });
            });
          },
          title: "Home"),
      NavItem(
          iconNormal: Icons.search_sharp,
          iconSelected: Icons.search,
          onPressed: () {
            switchPage(searchPage);
          },
          title: "Search"),
      NavItem(
          iconNormal: Icons.info_outline,
          iconSelected: Icons.info,
          onPressed: () {
            switchPage(homePage);
            Future.delayed(Duration(milliseconds: 100), () {
              setState(() {
                homeScrollController.animateTo(
                    homeScrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeIn);
              });
            });
          },
          title: "Info"),
    ];

    navBar =
        HorizontalNavbar(key: VerticalMainFrame.vNavBarKey, iconSize: 50, items: items);
  }

  void loginSuccess() {
    setState(() {
      onLogin = false;
    });
  }

  void switchPage(Widget? page) {
    if (page == null) {
      return;
    }

    setState(() {
      this.page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      maxWidth = constraints.maxWidth;
      maxHeight = constraints.maxHeight;

      return GestureDetector(
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
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
                    ),
                  ),
                  
                  SizedBox(height: 10,),
                  SizedBox(
                      height: 80,
                      width: double.infinity,
                      child: navBar),
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
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      color: onLogin
                          ? Colors.black.withOpacity(0.2)
                          : Colors.transparent,
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
