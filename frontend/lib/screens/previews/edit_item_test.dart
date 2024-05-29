import 'package:flutter/material.dart';
import 'package:frontend/screens/edit_item_screen.dart';
import '../../models/Session.dart';

void main() {
  runApp(MaterialApp(
    home: LoginAndFetchItem(),
  ));
}

class LoginAndFetchItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Session>(
      future: _login(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          return ItemDetailsScreen(itemId: 1);
        }
      },
    );
  }

  Future<Session> _login() async {
    var manager = SessionManager();
    return await manager.login("admin@example.com", "#123#AndresHinojosa#123");
  }
}
