import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {

    final List<String> images = [
        'assets/image1.jpg',
        'assets/image2.jpg',
        'assets/image3.jpg',
        'assets/image4.jpg',
      ];

    double screenWidth = MediaQuery.of(context).size.width;
    double pad_horizontal = 32 * 2;
    double pad_vertical = 16 * 1.25;
    double fontSizeButton = 18;
    double radioBorde = 20;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '¡Bienvenido!',
            style: TextStyle(
                fontSize: 95, color: Colors.white, fontWeight: FontWeight.bold),
            softWrap: true, // Permitir saltos de línea automáticos
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(radioBorde)),
            width: 850,
            child: Text(
              "Nos alegra que estés aquí. En el Laboratorio de Física, nos  esforzamos por ofrecerte la mejor experiencia posible, con contenido de calidad y recursos que te ayudarán a alcanzar tus objetivos.",
              style: TextStyle(color: Colors.white70, fontSize: 21),
              softWrap: true, // Permitir saltos de línea automáticos
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // Acción cuando se presiona el botón "Get Started"
                  print('Get Started');
                },
                child: Text('Iniciar Sesion'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Fondo negro
                  foregroundColor: Colors.white, // Texto blanco
                  padding: EdgeInsets.symmetric(
                      horizontal: pad_horizontal,
                      vertical: pad_vertical), // Tamaño más grande
                  textStyle: TextStyle(
                    fontSize: fontSizeButton, // Tamaño de la fuente
                    //fontWeight: FontWeight.bold, // Negrita
                  ),
                ),
              ),
              SizedBox(width: 20),
              OutlinedButton(
                onPressed: () {
                  // Acción cuando se presiona el botón "Info"
                  print('Informacion');
                },
                child: Text('Informacion'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black, // Color del texto
                  backgroundColor: Colors.white, // Fondo blanco
                  side:
                      BorderSide(color: Colors.black, width: 1), // Borde negro
                  padding: EdgeInsets.symmetric(
                      horizontal: pad_horizontal,
                      vertical: pad_vertical), // Tamaño más grande
                  textStyle: TextStyle(
                    fontSize: fontSizeButton, // Tamaño de la fuente
                    //fontWeight: FontWeight.bold, // Negrita
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
