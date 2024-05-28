import 'package:flutter/material.dart';

class BarraBusqueda extends StatefulWidget {
  static double height = 50;
  static double minWidth = 300;
  static double maxWidth = 400;

  final Function(String)? onSearch;
  final Function (String) onChange;

  final TextEditingController controller;
  const BarraBusqueda({super.key, this.onSearch, required this.onChange,  required this.controller});


  @override
  State<StatefulWidget> createState() {
    return BarraBusquedaState();
  }
}

class BarraBusquedaState extends State<BarraBusqueda>{
  bool isFocused = false;
  final FocusNode _focusNode = FocusNode();


  void focusChange(){
    setState(() {
      _focusNode.hasFocus? isFocused = true: isFocused=false;
    });
  }
  
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(focusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(focusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: BarraBusqueda.minWidth,
        ),
        child: LayoutBuilder(
            builder: (context, size) {

              double width = size.maxWidth;
              if(size.maxWidth > BarraBusqueda.maxWidth){
                width = BarraBusqueda.maxWidth;
              }
              else if(size.maxWidth < BarraBusqueda.minWidth){
                width = BarraBusqueda.minWidth;
              }


              return Container(
                height: BarraBusqueda.height,
                width: width,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: isFocused
                    ? Border.all(width: 2, color: Colors.white,)
                    : Border.all(width: 0, color: Colors.transparent),
                  borderRadius: BorderRadius.circular(BarraBusqueda.height),
                ),
                child: Center(
                  child: TextField(
                    controller: widget.controller,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,),
                    decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.fromLTRB(
                              BarraBusqueda.height/6, 0,
                              BarraBusqueda.height/9, 0),
                          child: Icon(Icons.search,
                            color: Colors.white.withAlpha(150),
                            size: BarraBusqueda.height/2,),
                        ),
                        hintText: 'Buscar',
                        hintStyle: TextStyle(
                            color: Colors.white.withAlpha(150),
                            fontSize: BarraBusqueda.height/3.5
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: (BarraBusqueda.height - BarraBusqueda.height / 3.5) / 2 - 7,
                          horizontal: BarraBusqueda.height / 6,
                        )
                    ),

                    focusNode: _focusNode,
                    onSubmitted: widget.onSearch,
                    onChanged: widget.onChange,

                  ),
                ),
              );
            }
        ),
      ),
    );
  }

}


class InputFillResponse{
  String input = "" ;


}
