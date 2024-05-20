import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '¡Bienvenido!',
            style: TextStyle(
                fontSize: 95, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
              "Nos alegra que estés aquí. En [Nombre de tu Página Web], nos esforzamos por ofrecerte la mejor experiencia posible, con contenido de calidad y recursos que te ayudarán a alcanzar tus objetivos."),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // Acción cuando se presiona el botón "Get Started"
                  print('Get Started');
                },
                child: Text('Get Started'),
              ),
              SizedBox(width: 20),
              OutlinedButton(
                onPressed: () {
                  // Acción cuando se presiona el botón "Info"
                  print('Info');
                },
                child: Text('Info'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
