import "package:flutter/material.dart";

class ResizablePanel extends StatelessWidget{
  static double minHeight = 600;
  List<double> stops;
  final double width;
  final Widget child;

  ResizablePanel({
    super.key,
    required this.child,
    required this.width,
    this.stops = const []
  }){
    if(stops.isNotEmpty) stops.sort();
  }

  @override
  Widget build(BuildContext context){


    double width = this.width;

    if(this.width != double.infinity){
      for(int i = 0; i < stops.length; i++){
        if(width <= stops[i] || i == stops.length-1){
          width = stops[i];
          break;
        }
      }
    }


    return ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: ResizablePanel.minHeight,
            maxHeight: double.infinity,
        ),
        child: SizedBox(
          width: width,
          height: double.infinity,
          child: child,
        ),
    );
  }
}