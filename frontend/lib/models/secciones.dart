import 'package:flutter/material.dart';
import 'widgets.dart'; // Asegúrate de que los widgets de tarjetas están aquí

class CustomHorizontalCardSection extends StatelessWidget {
  const CustomHorizontalCardSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        shrinkWrap: true, // Para que el GridView se ajuste al contenido
        physics:
            NeverScrollableScrollPhysics(), // Para deshabilitar el desplazamiento independiente
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Número de tarjetas por fila
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
          childAspectRatio:
              3 / 1, // Ajusta la proporción según el diseño de tus tarjetas
        ),
        itemCount:
            8, // Número total de tarjetas a mostrar, ajustar según necesidad
        itemBuilder: (context, index) {
          return CustomHorizontalCardWidget();
        },
      ),
    );
  }
}
