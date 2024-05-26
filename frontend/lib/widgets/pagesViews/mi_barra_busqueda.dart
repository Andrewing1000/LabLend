import 'package:flutter/material.dart';

class MyBarraBusqueda extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const MyBarraBusqueda({
    Key? key,
    required this.hintText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        style: TextStyle(color: Colors.white60),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
