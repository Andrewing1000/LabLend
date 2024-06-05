import 'package:flutter/material.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime?> onDateChanged;

  const CustomDatePicker({super.key, 
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
  });

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CalendarDatePicker(
              initialDate: widget.initialDate,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onDateChanged: (date) {
                setState(() {
                  if (selectedDate == date) {
                    selectedDate = null;
                  } else {
                    selectedDate = date;
                  }
                  widget.onDateChanged(selectedDate);
                });
              },
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
