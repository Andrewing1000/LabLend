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
  VerticalNavbarState createState() => VerticalNavbarState();
}

class VerticalNavbarState extends State<VerticalNavbar> {

  NavItem? selected;

  @override
  void initState() {
    super.initState();
    if(widget.items.length == 0){
      selected = null;
    }
    else{
      selected = widget.items[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(21, 21, 21, 1.0),
        borderRadius: BorderRadius.circular(widget.iconSize/4),
      ),
      width: 2*widget.iconSize,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: widget.items.map((item) {
              return CustomIconButton(iconNormal: item.iconNormal,
                                        iconSelected: item.iconSelected,
                                        isSelected: selected == item,
                                        onPressed: (){  setSelectedIndex(item);
                                                        if(item.onPressed!=null){
                                                          item.onPressed!();
                                                        }},
                                        size: widget.iconSize);
            }).toList(),
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

class NavItem {
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
