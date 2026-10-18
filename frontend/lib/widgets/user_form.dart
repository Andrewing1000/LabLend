import 'package:flutter/material.dart';
import 'package:frontend/models/Permissions.dart';
import 'package:frontend/models/Role.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/widgets/boton_agregar.dart';
import 'package:frontend/widgets/role_selector.dart';
import 'package:frontend/widgets/string_field.dart';
import '../models/User.dart';

class UserForm extends StatefulWidget {
  final User? user;
  /// email, nombres, apellido paterno, apellido materno, roles, activo
  final Function(String, String, String, String, List<String>, bool)
      onFormSubmit;

  const UserForm({
    super.key,
    this.user,
    required this.onFormSubmit,
  });

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidoPaternoController = TextEditingController();
  final TextEditingController apellidoMaternoController = TextEditingController();
  /// Roles que existen en el servidor (D15), para elegir los de la cuenta.
  List<Role> availableRoles = [];
  Set<String> selectedRoles = {};
  bool isActive = true;

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
      usernameController.text = widget.user?.username ?? '';
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
    usernameController.dispose();
    emailController.dispose();
    nombresController.dispose();
    apellidoPaternoController.dispose();
    apellidoMaternoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // D27: las cuentas de administrador de seguridad (la propia incluida)
    // no se editan desde aquí; cada uno usa su perfil.
    bool activeSwitch = !updateMode || !lockedAccount;

    double fieldWidth = MediaQuery.of(context).size.width * 0.8;

    return Column(
      children: [
        if (updateMode) ...[
          StringField(
            required: false,
            enabled: false,
            controller: usernameController,
            hintText: widget.user!.username,
            labelText: "Código de usuario",
            width: fieldWidth,
          ),
          const SizedBox(height: 20),
        ],
        StringField(
          required: !updateMode,
          enabled: !updateMode,
          controller: emailController,
          hintText: updateMode ? widget.user!.email : '',
          labelText: "Correo electrónico",
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        const SizedBox(height: 20),
        StringField(
          required: !updateMode,
          controller: nombresController,
          enabled: activeSwitch,
          hintText: updateMode ? widget.user!.nombres : 'Juan Carlos',
          labelText: "Nombres",
          width: fieldWidth,
        ),
        const SizedBox(height: 20),
        StringField(
          required: !updateMode,
          controller: apellidoPaternoController,
          enabled: activeSwitch,
          hintText: updateMode ? widget.user!.apellidoPaterno : 'Pérez',
          labelText: "Apellido paterno",
          width: fieldWidth,
        ),
        const SizedBox(height: 20),
        StringField(
          required: false,
          controller: apellidoMaternoController,
          enabled: activeSwitch,
          hintText: updateMode ? widget.user!.apellidoMaterno : 'Gutiérrez (opcional)',
          labelText: "Apellido materno",
          width: fieldWidth,
        ),
        const SizedBox(height: 20),
        // El administrador nunca escribe contraseñas: la cuenta nueva recibe
        // un enlace de activación (D26) y una existente, uno de
        // restablecimiento desde la pantalla de edición (D14, D24).
        if (availableRoles.isNotEmpty)
          SizedBox(
            width: fieldWidth,
            child: RoleSelector(
              roles: availableRoles,
              selected: selectedRoles,
              existingAccount: updateMode,
              enabled: canAssignRoles && !lockedAccount,
              onChanged: (roles) => setState(() => selectedRoles = roles),
            ),
          )
        else if (updateMode)
          Text(
            widget.user!.roles.isEmpty
                ? 'Sin roles'
                : 'Roles: ${widget.user!.roles.join(', ')}',
            style: const TextStyle(color: Colors.white70),
          ),
        const SizedBox(height: 20),
        if(activeSwitch)
          Row(
          children: [
            Checkbox(
              value: isActive,
              onChanged: (bool? value) {
                setState(() {
                  isActive = value!;
                });
              },
              checkColor: Colors.white,
              activeColor: Colors.orange,
            ),
            const Text(
              'Activo',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (lockedAccount)
          const Text(
            'Las cuentas con roles de seguridad no se modifican desde '
            'aquí: cada uno cambia sus datos desde su perfil.',
            style: TextStyle(color: Colors.white70),
          )
        else
        BotonAgregar(
          icon: updateMode ? Icons.update : Icons.add,
          onPressed: () {
            widget.onFormSubmit(
              emailController.text,
              nombresController.text,
              apellidoPaternoController.text,
              apellidoMaternoController.text,
              selectedRoles.toList(),
              isActive,
            );
          },
        ),
      ],
    );
  }
}
