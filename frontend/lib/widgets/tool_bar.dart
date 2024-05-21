import 'package:flutter/material.dart';
import 'package:frontend/widgets/barra_busqueda.dart';
import 'package:frontend/widgets/cicular_button.dart';

class ToolBar extends StatefulWidget{
  static double height = 130;

  ToolBar({super.key});

  @override
  State<ToolBar> createState(){
    return ToolBarState();
  }
}

class ToolBarState extends State<ToolBar>{

  @override
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: Colors.indigo,
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
                size: 25,
                isSelected: true,
                onPressed: (){
                  setState(() {

                  });
                },
              ),
              Container(width: 10,),
              CircularButton.static(
                normalIcon: Icons.arrow_forward_ios,
                size: 25,
                isSelected: true,
                onPressed: (){
                  setState(() {

                  });
                },
              ),
              Container(width: 10,),

              Expanded(
                  child: BarraBusqueda(onSearch: (e){})
              ),

              Container(width: 10,),
              Spacer(),

              CircularButton.animated(
                normalIcon: Icons.notifications_none_outlined,
                selectedIcon: Icons.notifications,
                size: 25,
                isSelected: true,
                onPressed: (){
                  setState(() {

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

                  });
                },
              ),

            ],
          ),
          Container(height: 20,),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              Container(width: 10,),

              Container(
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              Container(width: 10,),
              Container(
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}