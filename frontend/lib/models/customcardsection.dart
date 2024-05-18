import 'package:flutter/material.dart';
import 'package:frontend/models/widgets.dart'; // Asegúrate de que los widgets de tarjetas están aquí

class CustomCardSection extends StatelessWidget {
  const CustomCardSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        shrinkWrap: true, // Para que el GridView se ajuste al contenido
        physics: NeverScrollableScrollPhysics(), // Para deshabilitar el desplazamiento independiente
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Número de tarjetas por fila, ajustar según necesidad
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
          childAspectRatio: 640 / 300, // Proporción de la tarjeta original (ancho/alto)
        ),
        itemCount: 6, // Número total de tarjetas a mostrar, ajustar según necesidad
        itemBuilder: (context, index) {
          return CustomCardWidget();
        },
      ),
    );
  }
}
