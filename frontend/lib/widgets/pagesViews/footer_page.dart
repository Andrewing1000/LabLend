import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/widgets/pagesViews/LinkText.dart';

class Footer extends StatelessWidget {
  //double widthContainers = 0;
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double widthContainers = size.width * 0.3;
    double heightContainers = 600;
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
          color: Colors.black87,
        ),
        Padding(
          padding: const EdgeInsets.all(25),
          child: Center(
            child: SizedBox(
              height: size.height,
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Primera Columna
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(35)),
                    height: heightContainers,
                    width: widthContainers,
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
                                Linktext(
                                    text: "   Únete a Facebook",
                                    url:
                                        'https://www.facebook.com/pages/Universidad-Cat%C3%B3lica/377175925675553'),
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
                                Linktext(
                                    text: "   Ir a Instagram",
                                    url: 'https://www.instagram.com/'),
                                Icon(
                                  FontAwesomeIcons.squareInstagram,
                                  color: Colors.pink,
                                  size: 45,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              textDirection: TextDirection.rtl,
                              children: [
                                Linktext(
                                    text: "   Siguenos en X",
                                    url: 'https://x.com/?lang=es'),
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
                                Linktext(
                                    text: "   Entra a Github",
                                    url: 'https://github.com/'),
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
                                Linktext(
                                    text: "  Enviar Whatsapp",
                                    url: 'https://web.whatsapp.com/'),
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
                  // Sgunda Columna
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(35)),
                    height: heightContainers,
                    width: widthContainers,
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
                        SizedBox(
                            width: widthContainers * 0.7,
                            height: 250,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(30),
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/location.png'))),
                            )),
                        Icon(
                          FontAwesomeIcons.mapLocation,
                          color: Colors.red.shade700,
                          size: 70,
                        ),
                      ],
                    ),
                  ),
                  // Tercera Columna
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(35)),
                      height: heightContainers * 0.7,
                      width: widthContainers,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/ucblogo.png'),
                                  fit: BoxFit.scaleDown)),
                        ),
                      )),
                ],
              ),
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
