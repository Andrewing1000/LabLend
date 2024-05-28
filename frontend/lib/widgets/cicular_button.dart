import 'package:flutter/material.dart';


class CircularButton extends StatefulWidget{

  final IconData normalIcon;
  final IconData? selectedIcon;
  final double size;
  final bool isSelected;
  final bool isAvailable;
  final bool isAnimated;
  final Function? onPressed;

  const CircularButton.animated({super.key,
    required this.normalIcon,
    this.selectedIcon,
    required this.isSelected,
    required this.size,
    this.isAvailable = true,
    required this.onPressed,
    this.isAnimated = true});

  const CircularButton.static({super.key,
    required this.normalIcon,
    this.selectedIcon,
    required this.isSelected,
    required this.size,
    this.isAvailable = true,
    required this.onPressed,
    this.isAnimated = false});

  @override
  State<CircularButton> createState(){
    return CircularButtonState();
  }
}


class CircularButtonState extends State<CircularButton>{

  bool isHovered = false;


  void _onEnter(PointerEvent event){
    setState(() {
      isHovered = true;
    });
  }

  void _onExit(PointerEvent event){
    setState(() {
      isHovered = false;
    });
  }

  void _onPressed(){
    if(!widget.isAvailable) return;
    setState(() {
      final callback = widget.onPressed;
      if(callback != null){
        callback();
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: widget.isAvailable? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.5, end: isHovered? 1:0.5),
        duration: const Duration(milliseconds: 150),
        builder: (context, value, child){

          Color color = Color.fromRGBO(255, 255, 255, value);
          if(!widget.isAnimated || !widget.isAvailable || widget.isSelected){
             color = const Color.fromRGBO(255, 255, 255, 1);
          }

          Icon icon = Icon(
            widget.isSelected && widget.selectedIcon!=null && widget.isAvailable
                ? widget.selectedIcon
                : widget.normalIcon,
            color: color,
            size: widget.isAnimated && widget.isAvailable? (0.05*value+0.975)*widget.size : widget.size,
          );

          return Opacity(opacity: widget.isAvailable? 1 : 0.5,

              child: CircleAvatar(
                radius: 0.8*widget.size,
                backgroundColor: Colors.black,
                foregroundColor: Colors.transparent,

                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    radius: 0.6*widget.size,
                    splashColor:  Colors.white.withAlpha(100),
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTap: (){
                      setState(() {
                        _onPressed();
                      });
                    },

                    child: Align(
                      alignment: Alignment.center,
                      child: icon,
                      ),
                    ),
                  ),
                ),
          );
        },
      ),
    );
  }
}