import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '¡Bienvenido!',
            style: TextStyle(fontSize: 70),
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