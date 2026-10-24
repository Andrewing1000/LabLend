import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/models/Permissions.dart';
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
      List<String> roles, bool isActive) async {
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
    if(!_sameRoles(roles, newUser.roles)){
      noEdits = false;
      newUser.roles = roles;
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

  bool _sameRoles(List<String> a, List<String> b) =>
      a.length == b.length && a.toSet().containsAll(b);

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
              // Cuenta bloqueada por intentos fallidos (D23): se desbloquea
              // cuando su dueño elige una contraseña nueva.
              if (widget.user.isLocked)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    widget.user.securityAccount
                        ? 'Cuenta bloqueada por intentos fallidos. Se '
                            'desbloquea en el servidor con changepassword.'
                        : 'Cuenta bloqueada por intentos fallidos. Se '
                            'desbloquea cuando la persona elige una '
                            'contraseña nueva con un enlace de '
                            'restablecimiento.',
                    style: const TextStyle(color: AppColors.warning),
                  ),
                ),
              // El servidor no genera enlaces para cuentas de administrador
              // de seguridad (D27) ni para cuentas desactivadas, y solo a
              // quien tiene el permiso de generarlos (D17).
              if (SessionManager().session.user
                      .can(AppPermission.generarEnlaces) &&
                  !widget.user.securityAccount &&
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
