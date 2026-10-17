import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/widgets/boton_agregar.dart';
import 'package:frontend/widgets/string_field.dart';
import 'package:frontend/widgets/password_creation_field.dart';
import '../models/User.dart';

class UserForm extends StatefulWidget {
  final User? user;
  /// email, nombres, apellido paterno, apellido materno, contraseña, rol, activo
  final Function(String, String, String, String, String, Role, bool)
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
  final TextEditingController passwordController = TextEditingController();
  List<Role> roles = [Role.adminRole, Role.assistantRole];
  Role selectedRole = Role.assistantRole;
  bool isActive = true;

  bool get updateMode => widget.user != null;

  /// El rol de administrador de seguridad no se asigna ni se quita (D18):
  /// en su cuenta el rol se muestra, pero no se puede cambiar.
  bool get roleLocked => selectedRole == Role.securityAdminRole;

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
      selectedRole = widget.user?.role ?? Role.assistantRole;
      if (!roles.contains(selectedRole)) {
        roles = [selectedRole];
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    nombresController.dispose();
    apellidoPaternoController.dispose();
    apellidoMaternoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool activeSwitch = !updateMode || (!SessionManager().session.user.superAdmin &&
        SessionManager().session.user.email != widget.user!.email);

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
        PasswordCreationField(
          controller: passwordController,
          hintText: 'Contraseña',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        const SizedBox(height: 20),
        DropdownButton<Role>(
          value: selectedRole,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          items: roles.map((Role role) {
            return DropdownMenuItem<Role>(
              value: role,
              child: Text(
                role.name,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: roleLocked ? null : (Role? newRole) {
            setState(() {
              selectedRole = newRole!;
            });
          },
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
        BotonAgregar(
          icon: updateMode ? Icons.update : Icons.add,
          onPressed: () {
            widget.onFormSubmit(
              emailController.text,
              nombresController.text,
              apellidoPaternoController.text,
              apellidoMaternoController.text,
              passwordController.text,
              selectedRole,
              isActive,
            );
          },
        ),
      ],
    );
  }
}
