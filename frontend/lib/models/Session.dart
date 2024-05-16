import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'User.dart';


class Session {
  final User user;
  final DateTime loginTime;

  Session({required this.user, required this.loginTime});
}


class SessionManager with ChangeNotifier {
  List<Session> _sessions = [];

  List<Session> get sessions => _sessions;
}