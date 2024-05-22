import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Center(
        child: Stack(
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/place_holder.png'),
                  fit: BoxFit.cover)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Text(
              "Informacion: ",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
        ),
        Container(
          color: Colors.black.withOpacity(0.5),
        ),
        Padding(
          padding: const EdgeInsets.all(25),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(35)),
                  height: 500,
                  width: size.width * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Más informacion : ",
                        style: TextStyle(
                          fontSize: 35,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.info_outline,
                        color: Colors.amber.shade100,
                        size: 65,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                ' Comentanos en Facebook ',
                                style: TextStyle(
                                    fontSize: 19, color: Colors.amber),
                              ),
                              Icon(
                                Icons.facebook,
                                color: Colors.blue,
                                size: 45,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                ' Encuentranos en Instagram ',
                                style: TextStyle(
                                    fontSize: 19, color: Colors.amber),
                              ),
                              Icon(
                                Icons.camera,
                                color: Colors.pink,
                                size: 45,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                ' Siguenos en X ',
                                style: TextStyle(
                                    fontSize: 19, color: Colors.amber),
                              ),
                              Icon(
                                FontAwesomeIcons.xTwitter,
                                color: Colors.white,
                                size: 45,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                ' Siguenos en GitHub ',
                                style: TextStyle(
                                    fontSize: 19, color: Colors.amber),
                              ),
                              FaIcon(
                                FontAwesomeIcons.github,
                                color: Colors.blueGrey,
                                size: 45,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                ' Escribenos al WhatsApp ',
                                style: TextStyle(
                                    fontSize: 19, color: Colors.amber),
                              ),
                              FaIcon(
                                FontAwesomeIcons.whatsapp,
                                color: Colors.green,
                                size: 45,
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(35)),
                  height: 500,
                  width: size.width * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Ubicacion sede : ",
                        style: TextStyle(
                          fontSize: 35,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        FontAwesomeIcons.mapLocation,
                        color: Colors.red.shade700,
                        size: 70,
                      ),
                    ],
                  ),
                ),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(35)),
                    height: 500,
                    width: size.width * 0.3,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/images/ucblogo.png'),
                                fit: BoxFit.scaleDown)),
                      ),
                    )),
              ],
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            child: Text("Laboratorio de Fìsica",
                style: TextStyle(
                  fontSize: 65,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
          ),
        )
      ],
    ));
  }
}
