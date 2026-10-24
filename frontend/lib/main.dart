import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/themes/theme_controller.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Modo noche o día antes del primer dibujo, para que no parpadee.
  await ThemeController.instance.load(PlatformDispatcher.instance.platformBrightness);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeTransitionHost(
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        // El cambio de modo lo anima ThemeTransitionHost; sin esto, el tema
        // también se interpolaría y se verían colores intermedios.
        themeAnimationDuration: Duration.zero,
        // Calendario, menús y demás textos de Flutter en español.
        locale: const Locale('es'),
        supportedLocales: const [Locale('es'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
            body: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: SessionManager()),
          ],
          child: Consumer<SessionManager>(
            builder: (context, sessionManager, child) {
              return SessionManager.mainFrame;
            },
          ),
        )),
      ),
    );
  }
}
