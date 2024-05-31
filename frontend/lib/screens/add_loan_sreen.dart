import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan Management',
      home: LoanScreen(),
    );
  }
}

class LoanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Realizar Prestamo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 125),
              height: 200,
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(209, 0, 24, 206), // Black with full opacity
                    Color.fromARGB(
                        255, 0, 221, 255), // Dark gray with full opacity
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Text(
                  'Lista de Prestamos',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            LoanDetailCard(
              ci: '12345678',
              date: '11/10/2024',
              time: '13:15',
              name: 'Manuel Cardenas',
              equipment: 'Fuente de Voltaje',
              quantity: '1',
            ),
            SizedBox(height: 10),
            LoanDetailCard(
              ci: '12345678',
              date: '11/10/2024',
              time: '13:15',
              name: 'Manuel Cardenas',
              equipment: 'Fuente de Voltaje',
              quantity: '1',
            ),
            SizedBox(height: 10),
            LoanDetailCard(
              ci: '12345678',
              date: '11/10/2024',
              time: '13:15',
              name: 'Manuel Cardenas',
              equipment: 'Fuente de Voltaje',
              quantity: '1',
            ),
          ],
        ),
      ),
    );
  }
}

class LoanDetailCard extends StatelessWidget {
  final String ci;
  final String date;
  final String time;
  final String name;
  final String equipment;
  final String quantity;

  LoanDetailCard({
    required this.ci,
    required this.date,
    required this.time,
    required this.name,
    required this.equipment,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(label: 'CI', value: ci),
            InfoRow(label: 'Fecha', value: date),
            InfoRow(label: 'Hora', value: time),
            InfoRow(label: 'Realizado por', value: name),
            InfoRow(label: 'Equipo', value: equipment),
            InfoRow(label: 'Cantidad', value: quantity),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label + ':',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              value,
              style: TextStyle(color: Colors.greenAccent),
            ),
          ],
        ),
      ),
    );
  }
}
