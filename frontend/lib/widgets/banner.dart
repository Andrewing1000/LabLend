
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import 'dart:typed_data' as DartData;
class BannerWidget extends StatefulWidget {
  final DartData.Uint8List? imageUrl;
  final String title;
  final String subtitle;
  final String description;

  const BannerWidget({
    Key? key,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.description,
  }) : super(key: key);

  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  Color dominantColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _updatePalette();
  }

  Future<void> _updatePalette() async {
    if(widget.imageUrl == null){
      dominantColor = Colors.black;
      return;
    }

    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      MemoryImage(widget.imageUrl!),
    );
    setState(() {
      dominantColor = generator.dominantColor?.color ?? Colors.black;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [dominantColor, dominantColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
