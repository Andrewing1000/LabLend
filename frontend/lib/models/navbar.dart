import 'package:flutter/material.dart';

class VerticalNavbar extends StatelessWidget {
  final List<NavItem> items;
  final Function(int) onItemSelected;
  final int selectedIndex;

  const VerticalNavbar({
    Key? key,
    required this.items,
    required this.onItemSelected,
    this.selectedIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(150.0), // Increased roundness
      child: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Enhance spacing
            children: items.map((item) {
              int index = items.indexOf(item);
              return GestureDetector(
                onTap: () => onItemSelected(index),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300), // Animacion
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? Color.fromARGB(255, 255, 202, 87)
                        : Colors.transparent, // Seleccion de color naranja
                    borderRadius:
                        BorderRadius.circular(30), // Rounded edges inside
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color:
                            selectedIndex == index ? Colors.white : Colors.grey,
                        size: 30,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: TextStyle(
                          color: selectedIndex == index
                              ? Colors.white
                              : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String title;

  NavItem({
    required this.icon,
    required this.title,
  });
}
