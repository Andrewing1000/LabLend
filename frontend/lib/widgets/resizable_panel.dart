import "package:flutter/material.dart";


class ResizablePanel extends StatefulWidget{
  static double minHeight = 600;


  final List<ResizeRange> stops;
  final Widget? child;
  final ResizeController? controller;


  ResizablePanel({
    super.key,
    this.child,
    this.stops = const [],
    this.controller,
  }){
    if(stops.isNotEmpty) {
      stops.sort((a, b) {
        return a.start.compareTo(b.start);
      },);
    }
  }


  @override
  State<ResizablePanel> createState(){
    return ResizablePanelState();
  }
}



class ResizablePanelState extends State<ResizablePanel>{

  double controlWidth;
  double width;
  ResizeController? controller;
  ResizablePanelState():
        controlWidth = 0,
        width = 0,
        controller = null,
        super(){
    controller = widget.controller;
    if(controller != null){
      controller?.addListener((double delta){
        setState(() {
          performResize(delta);
        });
      });
    }
  }

  void performResize(double delta){
    controlWidth += delta;
    for(int i = 0; i < widget.stops.length; i++){
      ResizeRange stop= widget.stops[i];
      if(stop.inRange(controlWidth) || i == widget.stops.length-1){
          if(stop.isPoint()){
            width = stop.start;
          }

          break;
        }
      }
  }

  @override
  Widget build(BuildContext context){

    double width = this.width;




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


class ResizeRange{
  double start;
  double end;
  ResizeRange({required this.start, required this.end});
  ResizeRange.point({required double point}):
    start = point,
    end = point;

  bool inRange(double width){
    return width >= start && width >= end;
  }

  bool isPoint(){
    return start == end;
  }
}


class ResizeController{
  List<Function(double)> listeners = [];
  ResizeController();

  void addListener(Function(double) listener){
    listeners.add(listener);
  }

  void widthUpdate({double delta = 0}){
    for(var callback in listeners){
      callback(delta);
    }
  }
}