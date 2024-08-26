import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/widgets/boton_agregar.dart';
import 'package:frontend/widgets/string_field.dart';
import 'package:frontend/widgets/password_creation_field.dart';
import '../models/User.dart';

class UserForm extends StatefulWidget {
  final User? user;
  final Function(String, String, String, Role, bool) onFormSubmit;

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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final List<Role> roles = [Role.adminRole, Role.assistantRole];
  Role selectedRole = Role.assistantRole;
  bool isActive = true;

  bool get updateMode => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (updateMode) {
      emailController.text = widget.user?.email ?? '';
      nameController.text = widget.user?.name ?? '';
      isActive = widget.user?.isActive ?? true;
      selectedRole = widget.user?.role ?? Role.assistantRole;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool activeSwitch = !updateMode || (!SessionManager().session.user.superAdmin &&
        SessionManager().session.user.email != widget.user!.email);

    return Column(
      children: [
        StringField(
          required: !updateMode,
          enabled: !updateMode,
          controller: emailController,
          hintText: updateMode ? widget.user!.email : '',
          labelText: "email",
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        const SizedBox(height: 20),
        StringField(
          required: !updateMode,
          controller: nameController,
          enabled: activeSwitch,
          hintText: updateMode ? widget.user!.name : '',
          labelText: "Nombre",
          width: MediaQuery.of(context).size.width * 0.8,
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
          onChanged: (Role? newRole) {
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
              nameController.text,
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
