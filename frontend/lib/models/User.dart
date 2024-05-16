import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';



class Role{
  static const String ADMIN_ROLE = '';
  static const String ASSISTANT_ROLE = '';
}



class User extends ChangeNotifier{
  String email;
  String name;
  String role;

  User({required this.email,
        required this.name,
        this.role = Role.ASSISTANT_ROLE});



}
