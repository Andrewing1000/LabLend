import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/screens/PageBase.dart';

import 'cicular_button.dart';

class DropdownDateFilter extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateFilter filter;

  DropdownDateFilter({
    super.key,
    this.initialDate,
    required this.filter,
  }):
    firstDate = DateTime(2024, 1, 1),
    lastDate = DateTime.now().add(const Duration(days: 1));

  @override
  CustomDatePickerState createState() => CustomDatePickerState();
}

class CustomDatePickerState extends State<DropdownDateFilter> {
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,

    );
    if(picked == null || picked == _selectedDate){
      if(_selectedDate == null) return;
      setState(() {
        _selectedDate = null;
        widget.filter.clearSelected();
      });
      return;
    }

    setState(() {
        _selectedDate = picked;
        widget.filter.select(picked);
      });
      return;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(200.0),
          border: Border.all(color: Colors.grey),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: 180,
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(Icons.calendar_today, color: Colors.white.withAlpha(150)),
                  Container(width: 20,),
                  if(_selectedDate != null) Text(
                    "${_selectedDate?.toLocal()}".split(' ')[0],
                    style: TextStyle(color: Colors.white.withAlpha(150)),
                  ),
                  Container(width: 20,),
                  if(_selectedDate != null) CircularButton.static(
                    isSelected: true,
                    normalIcon: Icons.close,
                    size: 20,
                    iconColor: Colors.white.withAlpha(150),
                    backgroundColor: Colors.grey[850]!,
                    onPressed: (){
                      setState(() {
                        _selectedDate = null;
                        widget.filter.clearSelected();
                      });
                    },
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
