import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/user_form.dart';
import 'package:frontend/widgets/password_link_dialog.dart';

import '../models/User.dart';

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
    final compact = AppBreakpoints.isCompact(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(
                icon: Icons.person_add_alt_1,
                title: 'Nuevo usuario',
                subtitle: 'Registre a una persona del laboratorio y elija sus roles.',
              ),
              UserForm(
                onFormSubmit: _createUser,
                onCancel: () => widget.manager?.removePage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Encabezado de las pantallas de formulario: ícono, título y una línea de
/// ayuda.
class PageHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const PageHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
