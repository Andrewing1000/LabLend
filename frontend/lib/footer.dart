import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: 1300,
        height: 900,
        color: Colors.grey.shade900,
        child: Column(children: [
          const SizedBox(
            height: 30,
          ),
          Container(
            alignment: Alignment.bottomRight,
            height: 550,
            width: 1100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                  image: NetworkImage(
                      'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQgByBT5IiAT_a2x9pUVb4VMoOrlzHH7Jrzj-HB5jzHlR4lNLMS'),
                  fit: BoxFit.cover,
                  colorFilter:
                      const ColorFilter.mode(Colors.black38, BlendMode.darken)),
            ),
            child: const Text(
              " Laboratorio UCB",
              style: TextStyle(
                color: Colors.white,
                fontSize: 65,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Column(
                //redes
                children: [
                  Text(
                    "  Redes Universidad",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "   Facebook",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "   Instagram",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "   Gmail",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                height: 250,
                width: 350,
                color: Colors.grey,
                child: Text(" "),
              ),
              const Expanded(
                child: Text(
                  "En el Laboratorio de la Universidad Catolica Boliviana, esatmos comprometidos con al excelencia academica y la investigacion.Nuestro Laboratorio ofrece una gama de materiales y recursos para apoyar el desarrollo de proyectos cientificos y academicos. En el Laboratorio de la Universidad Catolica ",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              )
            ],
          )
        ]),
      ),
    );
  }
}
