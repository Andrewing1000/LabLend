import 'package:flutter/material.dart';
import 'package:frontend/widgets/icon_button.dart';

class VerticalNavbar extends StatefulWidget {
  final List<NavItem> items;
  final double iconSize;

  const VerticalNavbar({
    super.key,
    required this.iconSize,
    required this.items,
  });

  @override
  State<StatefulWidget> createState() => VerticalNavbarState();
}

class VerticalNavbarState extends State<VerticalNavbar> {

  NavItem? selected;

  @override
  void initState() {

    super.initState();
    if(widget.items.isEmpty){
      selected = null;
    }
    else{
      selected = widget.items[0];
    }
  }

  @override
  Widget build(BuildContext context) {

    List<CustomIconButton> iconList = [];
    for(NavItem item in widget.items){
      iconList.add(CustomIconButton(
          iconNormal: item.iconNormal,
          iconSelected: item.iconSelected,
          isSelected: selected == item,
          size: widget.iconSize,
          onPressed: (){
            setSelectedIndex(item);
            if(item.onPressed!=null){
              item.onPressed!();
            }
          },
        )
      );
    }


    return FittedBox(
      fit: BoxFit.cover,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(21, 21, 21, 1.0),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(5),
        constraints: BoxConstraints(
          minWidth: widget.iconSize,
        ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:iconList,
          ),
      ),
    );
  }


  void setSelectedIndex(NavItem item){
    setState(() {
      selected = item;
    });
  }

}

class NavItem{
  final IconData iconNormal;
  final IconData? iconSelected;
  final Function? onPressed;
  final String title;

  NavItem({
    required this.iconNormal,
    this.iconSelected,
    required this.onPressed,
    required this.title,
  });
}


class NavBarController{
  List<NavItem> items;
  List<VerticalNavbarState> clients = [];

  NavBarController({this.items = const []});

  void addClient(VerticalNavbarState client){

  }
}
