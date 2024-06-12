import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/models/User.dart';
import 'package:frontend/widgets/icon_button.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';

class CardVista extends StatefulWidget {
  static double width = 200;
  static double height = (9.5 / 7) * width;

  final Function? onTap;
  final Function? onEdit;
  final Item item;
  final String imagePath;

  CardVista({
    super.key,
    required this.item,
    required this.imagePath,
    this.onTap,
    this.onEdit,
  });

  @override
  State<CardVista> createState() {
    return CardVistaState();
  }
}

class CardVistaState extends State<CardVista>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _onEnter(PointerEvent event) {
    setState(() {
      isHovered = true;
      _controller.forward();
    });
  }

  void _onExit(PointerEvent event) {
    setState(() {
      isHovered = false;
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.item),
      ],
      child: Consumer<Item>(
        builder: (context, item, child) {
          return Align(
            alignment: Alignment.center,
            child: MouseRegion(
              onEnter: _onEnter,
              onExit: _onExit,
              child: GestureDetector(
                onTap: () {
                  final callback = widget.onTap;
                  if (callback != null) {
                    callback();
                  }
                },
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Card(
                    color: isHovered
                        ? Colors.white.withAlpha(20)
                        : const Color.fromRGBO(21, 21, 21, 1.0),
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      width: CardVista.width,
                      height: CardVista.height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            height: CardVista.height * 5.8 / 9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                widget.imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Flexible(
                                flex: 6,
                                fit: FlexFit.tight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      item.nombre,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily:
                                            "/assets/fonts/Metropolis-Black.ttf",
                                      ),
                                    ),
                                    Text(
                                      item.description ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.7),
                                        fontFamily:
                                            "/assets/fonts/Metropolis-Black.ttf",
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.onEdit != null &&
                                  SessionManager().session.user is AdminUser)
                                Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child: CustomIconButton(
                                    iconNormal: Icons.edit,
                                    size: 30,
                                    isSelected: false,
                                    onPressed: () {
                                      final callback = widget.onEdit;
                                      if (callback != null) {
                                        callback();
                                      }
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
