
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/models/User.dart';
import 'package:frontend/widgets/icon_button.dart';
import 'package:provider/provider.dart';
import '../models/Item.dart';

class CustomCard extends StatefulWidget {
  static double width = 230;
  static double height = (9 / 7) * width;

  Function? onTap;
  Function? onEdit;
  Function? onDelete;
  Item item;
  CustomCard({super.key, required this.item, this.onTap, this.onEdit, this.onDelete});

  @override
  State<CustomCard> createState() {
    return CustomCardState();
  }
}

class CustomCardState extends State<CustomCard> {
  
  bool isHovered = false;
  
  
  void _onEnter(PointerEvent event){
    setState(() {
      isHovered = true;
    });
  }
  
  void _onExit(PointerEvent envent){
    setState(() {
      isHovered = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.item,),
      ],
      child: Consumer<Item>(
        builder: (context, item, child) {
          return Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: CustomCard.width,
                height: CustomCard.height,
                child: MouseRegion(
                  onEnter: _onEnter,
                  onExit: _onExit,

                  child: GestureDetector(

                    onTap: (){
                      final callback = widget.onTap;
                      if(callback != null){
                        callback();
                      }

                    },

                    child: Card(
                      color: isHovered? Colors.white.withAlpha(20) : const Color.fromRGBO(21, 21, 21, 1.0),
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return Container(
                                    height: constraints.maxWidth * (CustomCard.height/CustomCard.width) * 6.5 / 9,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        item.imagePath != null? item.imagePath! : "assets/images/place_holder.png",
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ));
                              }
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Flexible(
                                  flex: 6,
                                  fit: FlexFit.tight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        item.nombre,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: "/assets/fonts/Metropolis-Black.ttf",
                                        ),
                                      ),
                                      Text(
                                        item.description?? "",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: Color.fromRGBO(255, 255, 255, 0.7),
                                          fontFamily: "/assets/fonts/Metropolis-Black.ttf",
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),


                                if(widget.onEdit != null
                                    && SessionManager().session.user is AdminUser)
                                  Flexible(
                                    flex: 2,
                                    fit: FlexFit.tight,
                                    child: CustomIconButton(
                                      iconNormal: Icons.edit,
                                      size: 30,
                                      isSelected: false,
                                      onPressed: (){
                                        final callback = widget.onEdit;
                                        if(callback != null){
                                          callback();
                                        }
                                      },
                                    )
                                ),

                                if(widget.onDelete != null
                                    && SessionManager().session.user is AdminUser)
                                  Flexible(
                                      flex: 2,
                                      fit: FlexFit.tight,
                                      child: CustomIconButton(
                                        iconNormal: Icons.delete,
                                        size: 30,
                                        isSelected: false,
                                        onPressed: (){
                                          final callback = widget.onDelete;
                                          if(callback != null){
                                            callback();
                                          }
                                        },
                                      )
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ));
        }
      ),
    );
  }
}
