import 'package:flutter/material.dart';

class BotonAgregar extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  const BotonAgregar({
    super.key,
    required this.icon,
    required this.onPressed,
  });

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
              icon,
              color: Colors.grey,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
