import 'package:frontend/themes/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Permissions.dart';
import 'package:frontend/models/Role.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/widgets/role_selector.dart';
import 'package:frontend/widgets/string_field.dart';
import '../models/User.dart';

/// Formulario de cuenta, para crearla o editarla. Va por secciones: datos
/// personales, roles y estado. El administrador nunca escribe contraseñas:
/// la cuenta nueva recibe un enlace de activación (D26) y una existente, uno
/// de restablecimiento desde la pantalla de edición (D14, D24).
class UserForm extends StatefulWidget {
  final User? user;
  /// email, nombres, apellido paterno, apellido materno, roles, activo
  final Function(String, String, String, String, List<String>, bool)
      onFormSubmit;
  final VoidCallback? onCancel;

  const UserForm({
    super.key,
    this.user,
    required this.onFormSubmit,
    this.onCancel,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidoPaternoController = TextEditingController();
  final TextEditingController apellidoMaternoController = TextEditingController();
  /// Roles que existen en el servidor (D15), para elegir los de la cuenta.
  List<Role> availableRoles = [];
  Set<String> selectedRoles = {};
  bool isActive = true;
  bool saving = false;

  bool get updateMode => widget.user != null;

  /// Asignar y quitar roles requiere su propio permiso (D15).
  bool get canAssignRoles =>
      SessionManager().session.user.can(AppPermission.asignarRoles);

  /// Cuenta con roles de seguridad abierta para editar: el servidor rechaza
  /// cualquier cambio (D27), así que el formulario es de solo lectura.
  bool get lockedAccount => updateMode && widget.user!.securityAccount;

  @override
  void initState() {
    super.initState();
    if (updateMode) {
      emailController.text = widget.user?.email ?? '';
      nombresController.text = widget.user?.nombres ?? '';
      apellidoPaternoController.text = widget.user?.apellidoPaterno ?? '';
      apellidoMaternoController.text = widget.user?.apellidoMaterno ?? '';
      isActive = widget.user?.isActive ?? true;
      selectedRoles = Set.of(widget.user!.roles);
    }
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    if (!SessionManager().session.user.can(AppPermission.verRoles)) return;
    final roles = await SessionManager.roleService.getRoles();
    if (mounted) setState(() => availableRoles = roles);
  }

  @override
  void dispose() {
    emailController.dispose();
    nombresController.dispose();
    apellidoPaternoController.dispose();
    apellidoMaternoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (saving) return;
    setState(() => saving = true);
    try {
      await widget.onFormSubmit(
        emailController.text.trim(),
        nombresController.text,
        apellidoPaternoController.text,
        apellidoMaternoController.text,
        selectedRoles.toList(),
        isActive,
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= AppBreakpoints.compact;
    final editable = !lockedAccount;

    Widget pair(Widget a, Widget b) => wide
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: a),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: b),
          ])
        : Column(children: [a, const SizedBox(height: AppSpacing.lg), b]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (lockedAccount)
          const _Notice(
            icon: Icons.admin_panel_settings_outlined,
            color: AppColors.warning,
            text: 'Las cuentas de administrador de seguridad no se modifican '
                'desde aquí: cada uno cambia sus datos desde su perfil.',
          ),

        // Datos personales
        FormSection(
          icon: Icons.badge_outlined,
          title: 'Datos personales',
          children: [
            if (updateMode) ...[
              pair(
                _ReadOnlyField(
                  label: 'Código de usuario',
                  value: widget.user!.username,
                  monospace: true,
                ),
                _ReadOnlyField(label: 'Correo electrónico', value: widget.user!.email),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'El código y el correo identifican a la persona: se fijan al crear la cuenta y no se cambian.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.lg),
            ] else ...[
              StringField(
                controller: emailController,
                hintText: 'jperez@ucb.edu.bo',
                labelText: 'Correo electrónico',
                prefixIcon: Icons.alternate_email,
                width: double.infinity,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            pair(
              StringField(
                required: !updateMode,
                controller: nombresController,
                enabled: editable,
                hintText: 'Juan Carlos',
                labelText: 'Nombres',
                width: double.infinity,
                textInputAction: TextInputAction.next,
              ),
              StringField(
                required: !updateMode,
                controller: apellidoPaternoController,
                enabled: editable,
                hintText: 'Pérez',
                labelText: 'Apellido paterno',
                width: double.infinity,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            pair(
              StringField(
                required: false,
                controller: apellidoMaternoController,
                enabled: editable,
                hintText: 'Gutiérrez',
                labelText: 'Apellido materno (opcional)',
                width: double.infinity,
              ),
              const SizedBox.shrink(),
            ),
            if (!updateMode) ...[
              const SizedBox(height: AppSpacing.md),
              const Text(
                'El código de usuario lo genera el sistema con el nombre y el apellido '
                '(por ejemplo, usr.jperez; adm. si tiene un rol de seguridad).',
                style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textMuted),
              ),
            ],
          ],
        ),

        // Roles
        FormSection(
          icon: Icons.verified_user_outlined,
          title: 'Roles',
          children: [
            if (availableRoles.isNotEmpty)
              RoleSelector(
                roles: availableRoles,
                selected: selectedRoles,
                existingAccount: updateMode,
                enabled: canAssignRoles && !lockedAccount,
                onChanged: (roles) => setState(() => selectedRoles = roles),
              )
            else
              Text(
                updateMode && widget.user!.roles.isNotEmpty
                    ? widget.user!.roles
                        .map((r) => r.replaceAllMapped(
                            RegExp(r'(?<=[a-záéíóúñ])(?=[A-ZÁÉÍÓÚÑ])'), (_) => ' '))
                        .join(', ')
                    : 'Sin roles',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            if (!canAssignRoles && !lockedAccount) ...[
              const SizedBox(height: AppSpacing.sm),
              const Text('No tiene permiso para asignar roles.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ],
        ),

        // Estado
        if (editable)
          FormSection(
            icon: Icons.toggle_on_outlined,
            title: 'Estado de la cuenta',
            children: [
              SwitchListTile(
                value: isActive,
                onChanged: (value) => setState(() => isActive = value),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text(isActive ? 'Cuenta activa' : 'Cuenta inactiva',
                    style: const TextStyle(color: AppColors.textPrimary)),
                subtitle: Text(
                  isActive
                      ? 'La persona puede iniciar sesión.'
                      : 'No puede iniciar sesión hasta que se reactive. Sus datos se conservan.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),

        if (!updateMode)
          const _Notice(
            icon: Icons.link,
            color: AppColors.primary,
            text: 'No se escribe ninguna contraseña. Al crear la cuenta se genera un '
                'enlace de activación (vence en 24 horas y sirve una sola vez) con el '
                'que la persona elige su propia contraseña.',
          ),

        if (editable) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              if (widget.onCancel != null)
                OutlinedButton(
                  onPressed: saving ? null : widget.onCancel,
                  style: OutlinedButton.styleFrom(minimumSize: const Size(140, 48)),
                  child: const Text('Cancelar'),
                ),
              FilledButton.icon(
                onPressed: saving ? null : _submit,
                style: FilledButton.styleFrom(minimumSize: const Size(180, 48)),
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                      )
                    : Icon(updateMode ? Icons.save_outlined : Icons.person_add_alt_1, size: 18),
                label: Text(updateMode ? 'Guardar cambios' : 'Crear usuario'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
  }
}

/// Sección del formulario: un título y su contenido, separada de la
/// siguiente por una línea fina.
class FormSection extends StatelessWidget {
  final IconData? icon;
  final String title;
  final List<Widget> children;

  const FormSection({super.key, this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

/// Dato que no se puede cambiar, mostrado como texto y no como campo
/// deshabilitado.
class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;

  const _ReadOnlyField({required this.label, required this.value, this.monospace = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontFamily: monospace ? 'monospace' : null,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Nota aclaratoria: texto en tono secundario, sin caja ni color.
class _Notice extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final String text;

  const _Notice({this.icon, this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Text(text,
          style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary)),
    );
  }
}
