import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/PageBase.dart';

class DropDownFilter extends StatefulWidget{
  Filter filter;

  DropDownFilter({super.key, required this.filter});

  @override
  State<StatefulWidget> createState() {
    return DropDownFilterState();
  }
}

class DropDownFilterState extends State<DropDownFilter>{
  @override
  Widget build(BuildContext context){
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.filter),
      ],
      child: Consumer<Filter>(
        builder: (context, filter, child){
          return DropdownButton(
              items: filter.items.map((item){
                    return DropdownMenuItem(
                        child: CheckboxListTile(
                          title: Text(filter.getRepresentation(item)),
                          value: filter.isSelected(item),
                          onChanged: (bool? value){
                            if(value!){
                              filter.select(item);
                            }
                            else{
                              filter.deselect(item);
                            }
                          },
                        ),
                      );
                  }
                ).toList(),
            onChanged: (value) {  },
          );
        },
      ),
    );
  }
}