// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:frontend/widgets/barra_busqueda.dart';
import 'package:frontend/widgets/cicular_button.dart';

class ToolBar extends StatefulWidget {
  static double height = 130;
  Function(String query) onConsult;
  bool searchEnabled;
  Function onLogin;

  ToolBar(
      {super.key,
      required this.onConsult,
      required this.onLogin,
      this.searchEnabled = true});

  @override
  State<ToolBar> createState() {
    return ToolBarState();
  }
}

class ToolBarState extends State<ToolBar> {
  // String de opcion seleccionada
  String? _selectedOption;
  // LIsta de Prueba
  final List<String> _options = [
    'Option 1',
    'Option 2',
    'Option 3',
    'Option 4'
  ];

  TextEditingController searchBarController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        // color: Color.fromARGB(255, 10, 224, 99),
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(10, 224, 99, 1),
            Color.fromARGB(255, 10, 150, 150),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              CircularButton.static(
                normalIcon: Icons.arrow_back_ios_new,
                size: 25,
                isSelected: true,
                onPressed: () {
                  setState(() {});
                },
              ),
              Container(
                width: 10,
              ),
              CircularButton.static(
                normalIcon: Icons.arrow_forward_ios,
                size: 25,
                isSelected: true,
                onPressed: () {
                  setState(() {});
                },
              ),
              Container(
                width: 10,
              ),
              if (widget.searchEnabled)
                Expanded(
                    child: BarraBusqueda(
                        controller: searchBarController,
                        onChange: (e) {
                          widget.onConsult(e);
                        },
                        onSearch: (e) {})),
              Container(
                width: 10,
              ),
              Spacer(),
              CircularButton.animated(
                normalIcon: Icons.notifications_none_outlined,
                selectedIcon: Icons.notifications,
                size: 25,
                isSelected: true,
                onPressed: () {
                  setState(() {});
                },
              ),
              Container(
                width: 10,
              ),
              CircularButton.animated(
                normalIcon: Icons.login,
                size: 25,
                isSelected: true,
                onPressed: () {
                  setState(() {
                    widget.onLogin();
                  });
                },
              ),
            ],
          ),
          Container(
            height: 20,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(170),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: Text(
                      "  Category",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    value: _selectedOption,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.white),
                    dropdownColor: Colors.black,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue;
                      });
                    },
                    items:
                        _options.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child:
                            Text(value, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                width: 10,
              ),
              Container(
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(170),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: Text(
                      "  Category",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    value: _selectedOption,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.white),
                    dropdownColor: Colors.black,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue;
                      });
                    },
                    items:
                        _options.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child:
                            Text(value, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                width: 10,
              ),
              Container(
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(170),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: Text(
                      "  Category",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    value: _selectedOption,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.white),
                    dropdownColor: Colors.black,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue;
                      });
                    },
                    items:
                        _options.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child:
                            Text(value, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
