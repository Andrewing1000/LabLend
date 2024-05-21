import 'package:flutter/material.dart';

class BarraBusqueda extends StatelessWidget {
  static double height = 50;
  static double minWidth = 300;
  static double maxWidth = 400;

  final Function(String) onSearch;

  const BarraBusqueda({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      heightFactor: 1,
      widthFactor: 1,
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
                borderRadius: BorderRadius.circular(BarraBusqueda.height),
              ),
              child: Center(
                child: TextField(
                  textAlign: TextAlign.left,
                  style: const TextStyle(color: Colors.white),
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
                        color: Colors.white54,
                        fontSize: BarraBusqueda.height/3.5),
                        border: InputBorder.none,
                  ),
                  onSubmitted: onSearch,
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
