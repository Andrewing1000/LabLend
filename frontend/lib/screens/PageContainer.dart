import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/tool_bar.dart';
import '../services/PageManager.dart';

class PageContainer extends StatefulWidget{
  PageManager manager;
  Function onLogin;
  Function onLogout;
  Function onCartLookup;
  /// Abre el cambio de la contraseña propia (D14, D21).
  Function? onChangePassword;

  PageContainer({
    super.key,
    required this.manager,
    required this.onLogin,
    required this.onLogout,
    required this.onCartLookup,
    this.onChangePassword,
  });


  @override
  State<StatefulWidget> createState() {
    return PageContainerState();
  }
}

class PageContainerState extends State<PageContainer>{

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.manager),
      ],
      child: Consumer<PageManager>(
        builder: (context, manager, snapshot) {
          return Column(
            children: [
              ToolBar(
                  manager: manager,
                  onLogin: widget.onLogin,
                  onLogout: widget.onLogout,
                  onCartLookup: widget.onCartLookup,
                  onChangePassword: widget.onChangePassword,
              ),

                  Expanded(child: manager.currentPage),

            ],
          );
        }
      ),
    );
  }
}