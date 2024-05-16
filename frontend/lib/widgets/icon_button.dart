import 'package:flutter/material.dart';

class CustomIconButton extends StatefulWidget {
  final IconData iconNormal;
  final IconData? iconSelected;
  final double size;
  Function? onPressed;
  List<Function> listeners = [];
  final bool isSelected;

  CustomIconButton({
    super.key,
    required this.iconNormal,
    this.iconSelected,
    required this.isSelected,
    required this.size,
    this.onPressed,
  });



  void addListener(Function listener){
    listeners.add(listener);
  }

  void removeListener(Function listener){
    listeners.remove(listener);
  }

  void clearListeners(){
    listeners.clear();
  }

  @override
  State<StatefulWidget> createState() {
    return IconButtonState();
  }
}

class IconButtonState extends State<CustomIconButton> {
  bool isHovered = false;

  void _onEnter(PointerEvent event) {
    setState(() {
      isHovered = true;
    });
  }

  void _onExit(PointerEvent event) {
    setState(() {
      isHovered = false;
    });
  }

  void _onPressed() {
    setState(() {
      final Function? callback = widget.onPressed;
      if(callback != null){
        setState(() {
          callback();
        });
      }

      for (var callback in widget.listeners) {callback();}
    });
  }

  @override
  Widget build(BuildContext context) {

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.4, end: isHovered ? 1 : 0.5),
        duration: const Duration(milliseconds: 150),
        builder: (context, value, child) {
          Icon icon = Icon(
            widget.isSelected && widget.iconSelected != null
                ? widget.iconSelected
                : widget.iconNormal,
            color: widget.isSelected? const Color.fromRGBO(255, 255, 255, 1) :Color.fromRGBO(255, 255, 255, value),

            size: (0.05*value+0.975)*widget.size,
          );

          return Padding(
            padding: EdgeInsets.all(widget.size/3),
            child: Center(
              heightFactor: 1.1,
              widthFactor: 1.1,
              child: IconButton(
                icon: icon,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                iconSize: widget.size,
                onPressed: _onPressed,
              ),
            ),
          );
        },
      ),
    );
  }
}
