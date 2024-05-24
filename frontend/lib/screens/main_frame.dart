import "package:flutter/material.dart";
import "package:frontend/screens/home_screen.dart";
import "package:frontend/widgets/navbar.dart";
import "package:frontend/widgets/resizable_panel.dart";

import "../widgets/tool_bar.dart";

class MainFrame extends StatefulWidget{
  static GlobalKey<VerticalNavbarState> vNavBarKey = GlobalKey();
  MainFrame({super.key});


  @override
  State<MainFrame> createState(){
    return MainFrameState();
  }
}

class MainFrameState extends State<MainFrame>{

  bool onFrontier1 = false;
  bool onFrontier2 = false;
  bool grabbing1 = false;
  bool grabbing2 = false;

  double width1 = 0;
  double width2 = 0;

  double maxWidth = double.infinity;
  double maxHeight = double.infinity;

  VerticalNavbar navBar;

  MainFrameState():
        navBar = VerticalNavbar(
          key: MainFrame.vNavBarKey,
          iconSize: 30,
          items: const [],),
          super(){

    final List<NavItem> items = [

      NavItem(
          iconNormal: Icons.home_outlined,
          iconSelected: Icons.home,
          onPressed: (){
            print("Opcion1");
          },
          title: "Home"),

      NavItem(
          iconNormal : Icons.search_sharp,
          iconSelected: Icons.search,
          onPressed: (){
            print("Opcion2");
          },
          title: "Search"),

      NavItem(
          iconNormal : Icons.info_outline,
          iconSelected: Icons.info,
          onPressed: (){
            print("Opcion3");
          },
          title: "Search"),

    ];


    navBar = VerticalNavbar(
        key: MainFrame.vNavBarKey,
        iconSize: 30,
        items: items);

  }

  @override
  void initState() {

    setState(() {
      width1 = 70;
      width2 = 100;
    });
  }




  void performResize(double dx){
    if(grabbing1){
      if(width1 + dx >= 0){
        setState(() {
          width1 += dx;
        });
      }
      return;
    }

    if(grabbing2){
      if(width2 + dx >= 0){
        setState(() {
          width2 -= dx;
        });
      }
      return;
    }
  }



  @override
  Widget build(BuildContext context){

    Widget page = HomeScreen();


    return LayoutBuilder(
      builder: (context, constraints) {


        maxWidth = constraints.maxWidth;
        maxHeight = constraints.maxHeight;


        return Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.black,
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResizablePanel(
                  width: width1,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: navBar,
                  )),
              MouseRegion(
                cursor:  SystemMouseCursors.grab,
                onEnter: (event){
                  setState(() {onFrontier1 = true;});
                },
                onExit: (event){
                  setState((){onFrontier1 = false;});
                },
                child: const SizedBox(
                  height: double.infinity,
                  width: 10,
                ),
              ),


              Expanded(
                child: ResizablePanel(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(21, 21, 21, 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [

                        HomeScreen(),
                        ToolBar(),
                      ],
                    ),
                  )
                ),
              ),
              MouseRegion(
                cursor:  SystemMouseCursors.grab,
                onEnter: (event){
                  setState(() {onFrontier2 = true;});
                },
                onExit: (event){
                  setState((){onFrontier2 = false;});
                },
                child: const SizedBox(
                  height: double.infinity,
                  width: 10,
                ),
              ),


              ResizablePanel(
                  width: width2,
                  stops: [200, 210, 305, 400, 600],
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(21, 21, 21, 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
              ),

            ],
          ),
        );
      }
    );
  }
}