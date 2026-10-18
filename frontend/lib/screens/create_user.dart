import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
// import 'package:frontend/models/Session.dart'; // Comentado para ver solo la vista
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/widgets/user_form.dart';
import 'package:frontend/widgets/password_link_dialog.dart';

import '../models/User.dart';
// import 'package:frontend/models/user.dart'; // Comentado para ver solo la vista

class CreateUserScreen extends PageBase{
  CreateUserScreen({super.key});

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();

  @override
  Future<PageBase> onDispose() async{
    return this;
  }

  @override
  Future<PageBase> onSet() async{
    return this;
  }
}

class _CreateUserScreenState extends State<CreateUserScreen> {


  /// Crea la cuenta sin contraseña y muestra una sola vez su enlace de
  /// activación, con el que su dueño elige la contraseña (D26).
  Future<void> _createUser(String email, String nombres,
      String apellidoPaterno, String apellidoMaterno,
      List<String> roles, bool isActive) async {
    if (email.isEmpty){
      SessionManager().errorNotification(error: "Se requiere el email de usuario");
      return;
    }

    if (nombres.trim().isEmpty || apellidoPaterno.trim().isEmpty){
      SessionManager().errorNotification(error: "Se requieren los nombres y el apellido paterno");
      return;
    }

    final User user = AccountUser(email: email, nombres: nombres.trim(),
        apellidoPaterno: apellidoPaterno.trim(),
        apellidoMaterno: apellidoMaterno.trim(), isActive: isActive,
        roles: roles);

    final rolesText = roles.isEmpty
        ? 'sin roles (solo podrá ver su perfil hasta recibir uno)'
        : 'con los roles ${roles.join(', ')}';
    final pass = await SessionManager().confirmNotification(message: "Se creará el usuario ${user.name} con email \"$email\", $rolesText");

    if(pass){
      final link = await user.create();
      if(link != null && mounted){
        await showPasswordLinkDialog(context, link);
        widget.manager?.removePage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const BannerWidget(
                    imageUrl: null,
                    title: "Registro de usuarios",
                    subtitle: "",
                    description: ""),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: UserForm(
                    onFormSubmit: _createUser,
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }
}
