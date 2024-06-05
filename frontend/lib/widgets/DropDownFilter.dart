import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/PageBase.dart';
import 'cicular_button.dart'; // Make sure the path is correct

class DropDownFilter extends StatefulWidget {
  final Filter filter;

  const DropDownFilter({super.key, required this.filter});

  @override
  State<StatefulWidget> createState() {
    return DropDownFilterState();
  }
}

class DropDownFilterState extends State<DropDownFilter> {
  @override
  Widget build(BuildContext context) {
    Filter filter = widget.filter;

    return FutureBuilder(
      future: filter.getItems(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        } else if (snapshot.hasError) {
          print(snapshot.error.toString());
          print("Se errory");
          return Container();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container();
        } else {
          List<dynamic> items = snapshot.data!;
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: filter),
            ],
            child: Consumer<Filter>(
              builder: (context, filter, child) {
                return DropdownMenu<dynamic>(
                  label: Text(
                    filter.attributeName,
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  textStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  requestFocusOnTap: true,
                  enableFilter: true,
                  enableSearch: true,
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    isDense: true,
                    fillColor: Colors.grey[850],
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(200),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(200),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  menuStyle: MenuStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Colors.grey[850],
                    ), // Set background color to black
                  ),
                  dropdownMenuEntries: filter.items.map((item) {
                    return DropdownMenuEntry(
                      value: item,
                      enabled: false,
                      label: filter.getRepresentation(item),
                      labelWidget: DropdownMenuItem(filter: filter, item: item,),
                      style: MenuItemButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.transparent,
                      ),
                      // Assuming CircularButton is a custom widget
                    );
                  }).toList(),
                );
              },
            ),
          );
        }
      },
    );
  }
}



class DropdownMenuItem extends StatelessWidget{
  Filter filter;
  dynamic item;
  DropdownMenuItem({super.key, required this.filter, required this.item});
  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        if (filter.isSelected(item)) {
          filter.deselect(item);
          return;
        }
        filter.select(item);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          CircularButton.static(
            size: 20,
            normalIcon: Icons.circle_outlined,
            selectedIcon: Icons.check_circle,
            isSelected: filter.isSelected(item),
            onPressed: () {
              if (filter.isSelected(item)) {
                filter.deselect(item);
                return;
              }
              filter.select(item);
            },
            backgroundColor: Colors.grey[900]!,
          ),

          Text(
            filter.getRepresentation(item),
            style: const TextStyle(
              color: Colors.white,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}