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
        super();

  @override
  void initState() {
    super.initState();
    if(widget.stops.isNotEmpty){

      width = widget.stops[0].start;
      controlWidth = width;
    }

    controller = widget.controller;
    if(controller != null){
      controller?.addClient(this);
    }
  }

  void performResize(double delta){

    controlWidth += delta;
    if(widget.stops.isEmpty){
      setWidth(controlWidth);
      return;
    }

    for(var stop in widget.stops.reversed){
      if(controlWidth >= stop.start || stop == widget.stops[0]){
          if(stop.isPoint()){
            if(width != stop.start) setWidth(stop.start);
          }
          else{
            if(stop.inRange(controlWidth)){setWidth(controlWidth);}
            else if(controlWidth > stop.end){setWidth(stop.end);}
            else{setWidth(stop.start);}
          }
          break;
        }
      }
  }

  void commitResize(){
    controlWidth = width;
  }


  void setWidth(double width){
    setState(() {
      this.width = width;
    });
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
          child: widget.child,
        ),
    );
  }
}


class ResizeRange{
  double start;
  double end;
  ResizeRange({required this.start, required this.end});
  ResizeRange.point(point):
    start = point,
    end = point;

  bool inRange(double width){
    return width >= start && width <= end;
  }

  bool isPoint(){
    return start == end;
  }
}


class ResizeController{
  List<ResizablePanelState> clients = [];
  ResizeController();


  void addClient(ResizablePanelState client){
    clients.add(client);
  }

  void widthUpdate({double delta = 0}){
    for(var client in clients){
      client.performResize(delta);
    }
  }

  void commitUpdate(){
    for(var client in clients){
      client.commitResize();
    }
  }
}