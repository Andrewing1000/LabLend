import 'package:flutter/material.dart';

class BarraBusqueda extends StatelessWidget {
  final Function(String) onSearch;
  final Function (String) onChange;

  const BarraBusqueda({Key? key, required this.onSearch, required this.onChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.white),
            hintText: 'Buscar',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
          onSubmitted: onSearch,
          onChanged: onChange,
        ),
      ),
    );
  }
}
class InputFillResponse{
  String input = "" ;


}