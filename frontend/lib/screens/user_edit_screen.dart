import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/models/Permissions.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/password_link_dialog.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/widgets/UserCard.dart';
import 'package:frontend/widgets/app_nav.dart';
import 'package:frontend/models/User.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/services/ContextMessageService.dart';

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
      SessionManager().notification(notification: "No hay cambios para guardar", kind: NotificationKind.info);
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
    final user = widget.user;
    final compact = AppBreakpoints.isCompact(context);
    // El servidor no genera enlaces para cuentas de administrador de
    // seguridad (D27) ni para cuentas desactivadas, y solo a quien tiene el
    // permiso de generarlos (D17).
    final canGenerateLink =
        SessionManager().session.user.can(AppPermission.generarEnlaces) &&
            !user.securityAccount &&
            user.isActive;

    return SingleChildScrollView(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _EditHeader(user: user),
              UserForm(
                user: user,
                onFormSubmit: _updateUser,
                onCancel: () => widget.manager?.removePage(),
              ),
              FormSection(
                icon: Icons.key_outlined,
                title: 'Acceso y contraseña',
                children: [
                  // Cuenta bloqueada por intentos fallidos (D23): se
                  // desbloquea cuando su dueño elige una contraseña nueva.
                  if (user.isLocked) ...[
                    Text(
                      user.securityAccount
                          ? 'Cuenta bloqueada por intentos fallidos. Se '
                              'desbloquea en el servidor con changepassword.'
                          : 'Cuenta bloqueada por intentos fallidos. Se '
                              'desbloquea cuando la persona elige una '
                              'contraseña nueva con un enlace de '
                              'restablecimiento.',
                      style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Text(
                    user.activationPending
                        ? 'La persona todavía no eligió su contraseña. Si perdió el enlace '
                            'de activación, genere uno nuevo: el anterior deja de servir.'
                        : 'El administrador nunca ve ni escribe contraseñas. Si la persona '
                            'la olvidó, genere un enlace de restablecimiento: vence en 24 horas '
                            'y sirve una sola vez.',
                    style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (canGenerateLink)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.link, size: 18),
                        label: Text(user.activationPending
                            ? 'Generar enlace de activación'
                            : 'Generar enlace de restablecimiento'),
                        onPressed: _createPasswordLink,
                      ),
                    )
                  else
                    Text(
                      user.securityAccount
                          ? 'Las cuentas de administrador de seguridad no reciben enlaces desde aquí.'
                          : !user.isActive
                              ? 'Reactive la cuenta para poder generarle un enlace.'
                              : 'No tiene permiso para generar enlaces.',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Encabezado de la edición: la persona, su código y el estado de la cuenta.
class _EditHeader extends StatelessWidget {
  final User user;
  const _EditHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.surfaceHighest, shape: BoxShape.circle),
                child: Text(userInitials(user),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text(user.username,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          AccountStatusBadge(status: AccountStatus.of(user)),
        ],
      ),
    );
  }
}
