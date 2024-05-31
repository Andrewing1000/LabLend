import 'package:flutter/material.dart';

class BotonAgregar extends StatelessWidget {
  final VoidCallback onPressed;

  const BotonAgregar({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.add,
              color: Colors.grey,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
