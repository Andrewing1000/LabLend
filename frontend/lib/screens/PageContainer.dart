import 'package:frontend/models/Session.dart';
import 'package:frontend/services/ContextMessageService.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/HomePage.dart';
import 'package:frontend/widgets/tool_bar.dart';
import '../services/PageManager.dart';

class PageContainer extends StatefulWidget{
  PageManager manager;
  Function onLogin;


  PageContainer({
    super.key,
    required this.manager,
    required this.onLogin,
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
          return Stack(
            children: [
              ToolBar(manager: manager, onLogin: widget.onLogin),
              Column(
                children: [
                  Container(
                    height: ToolBar.height,
                  ),
                  Expanded(child: manager.currentPage),
                ],
              ),
            ],
          );
        }
      ),
    );
  }
}