import 'package:frontend/themes/AppTheme.dart';


import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import 'dart:typed_data' as DartData;
class BannerWidget extends StatefulWidget {
  final DartData.Uint8List? imageUrl;
  final String title;
  final String subtitle;
  final String description;

  const BannerWidget({
    super.key,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  Color dominantColor = AppColors.background;

  @override
  void initState() {
    super.initState();
    _updatePalette();
  }

  Future<void> _updatePalette() async {
    if(widget.imageUrl == null){
      dominantColor = AppColors.background;
      return;
    }

    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      MemoryImage(widget.imageUrl!),
    );
    setState(() {
      dominantColor = generator.dominantColor?.color ?? AppColors.background;
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
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: AppColors.background,
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
