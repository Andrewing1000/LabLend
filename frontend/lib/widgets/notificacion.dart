import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/widgets/notificationCard.dart';

class ConfirmationWidget extends NotificationWidget {
  final String buttonText;
  final Completer<bool> completer;
  late Future<bool> promise;

  ConfirmationWidget({
    super.key,
    required super.message,
    required this.buttonText,
  }):
  completer = Completer<bool>();

  Future<bool> confirm(){
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    promise = completer.future;
    return GestureDetector(
      onTap: (){
        print("QUe psas");
        completer.complete(false);
      },
      child: Container(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onTap: (){
                  print("Yala");
                },
                child: Container(
                  width: 500, // Ajuste de ancho
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              GestureDetector(

                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    ElevatedButton(
                                      onPressed: () {
                                        print("Pinba-------------------->");
                                        completer.complete(true);

                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        backgroundColor: Theme.of(context).primaryColor,
                                      ),
                                      child: Text( buttonText,
                                          style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment(1, -1),
                          child: IconButton(onPressed: (){
                            completer.complete(false);
                          },
                              icon: const Icon(
                                Icons.clear,
                                size: 20,
                              )
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
