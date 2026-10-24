import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/themes/AppTheme.dart';

/// Texto que aparece letra por letra, como si se escribiera, con un cursor
/// que parpadea. Las letras que faltan se dibujan transparentes, así el texto
/// ocupa su tamaño final desde el inicio y nada se mueve mientras se escribe.
/// Si el sistema pide reducir las animaciones, se muestra completo.
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final Duration charDelay;
  final Duration startDelay;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.start,
    this.charDelay = const Duration(milliseconds: 90),
    this.startDelay = const Duration(milliseconds: 400),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  int visible = 0;
  Timer? timer;
  late final AnimationController blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 530),
  )..repeat(reverse: true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (timer != null || visible > 0) return;
    if (MediaQuery.of(context).disableAnimations) {
      visible = widget.text.length;
      return;
    }
    timer = Timer(widget.startDelay, () {
      timer = Timer.periodic(widget.charDelay, (t) {
        if (!mounted) return;
        setState(() => visible++);
        if (visible >= widget.text.length) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typed = widget.text.substring(0, visible);
    final pending = widget.text.substring(visible);
    final fontSize = widget.style.fontSize ?? 32;

    return Text.rich(
      TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: typed),
          // Cursor de ancho cero: parpadea sin empujar las letras.
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SizedBox(
              width: 0,
              height: fontSize * 0.8,
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: fontSize * 0.08,
                child: FadeTransition(
                  opacity: blink,
                  child: Container(
                    width: fontSize * 0.06,
                    margin: EdgeInsets.only(left: fontSize * 0.02),
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          TextSpan(text: pending, style: const TextStyle(color: Colors.transparent)),
        ],
      ),
      textAlign: widget.textAlign,
    );
  }
}
