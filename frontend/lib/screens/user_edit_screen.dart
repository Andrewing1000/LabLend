import 'package:flutter/material.dart';
import 'package:frontend/widgets/password_link_dialog.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/models/User.dart';
//import 'package:frontend/models/User.dart';
import 'package:frontend/models/Session.dart';

import '../widgets/user_form.dart';

class EditUserScreen extends PageBase{

  User user;
  EditUserScreen({super.key, required this.user}):
        super(disposable: true);

  @override
  EditUserScreenState createState() => EditUserScreenState();

  @override
  void onDispose() {
    return;
  }

  @override
  void onSet() {
    return;
  }
}

class EditUserScreenState extends State<EditUserScreen> {


  Future<void> _updateUser(String email, String nombres,
      String apellidoPaterno, String apellidoMaterno,
      Role role, bool isActive) async {
    User newUser = widget.user.clone();
    nombres = nombres.trim();
    apellidoPaterno = apellidoPaterno.trim();
    apellidoMaterno = apellidoMaterno.trim();

    bool noEdits = true;
    if(email != newUser.email && email.isNotEmpty){
      noEdits = false;
      newUser.email = email;
    }
    if(nombres != newUser.nombres && nombres.isNotEmpty){
      noEdits = false;
      newUser.nombres = nombres;
    }
    if(apellidoPaterno != newUser.apellidoPaterno && apellidoPaterno.isNotEmpty){
      noEdits = false;
      newUser.apellidoPaterno = apellidoPaterno;
    }
    if(apellidoMaterno != newUser.apellidoMaterno){
      noEdits = false;
      newUser.apellidoMaterno = apellidoMaterno;
    }
    if(role != newUser.role){
      noEdits = false;
      newUser.role = role;
    }
    if(isActive != newUser.isActive){
      noEdits = false;
      newUser.isActive = isActive;
    }

    if(noEdits){
      SessionManager().errorNotification(error: "No se registraron cambios");
      return;
    }

    final pass = await SessionManager().confirmNotification(message: "Confirmar la edición de usuario");
    if(pass){
      var res = await widget.user.update(newUser: newUser);
      if(res != null){
        widget.manager?.removePage();
      }
    }
  }

  /// Genera un enlace nuevo: de activación si la cuenta aún no eligió su
  /// contraseña (D26), de restablecimiento si ya la tiene (D24).
  Future<void> _createPasswordLink() async {
    final message = widget.user.activationPending
        ? "El enlace de activación anterior de ${widget.user.username} "
            "dejará de funcionar. ¿Generar uno nuevo?"
        : "La contraseña actual de ${widget.user.username} dejará de "
            "funcionar y se cerrarán sus sesiones. ¿Generar el enlace?";
    final confirmed =
        await SessionManager().confirmNotification(message: message);
    if (!confirmed) return;

    final link = await widget.user.createPasswordLink();
    if (link == null || !mounted) return;
    await showPasswordLinkDialog(context, link);
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
                  title: "Edición de usuarios",
                  subtitle: "",
                  description: ""),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: UserForm(
                  user: widget.user,
                  onFormSubmit: _updateUser,
                ),
              ),
              // El servidor no genera enlaces para cuentas de administrador
              // de seguridad (D27) ni para cuentas desactivadas.
              if (widget.user.role != Role.securityAdminRole &&
                  widget.user.isActive)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.link),
                    label: Text(widget.user.activationPending
                        ? 'Generar enlace de activación'
                        : 'Generar enlace de restablecimiento'),
                    onPressed: _createPasswordLink,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
