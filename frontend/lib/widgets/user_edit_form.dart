import 'package:flutter/material.dart';
import 'package:frontend/models/User.dart';
import 'package:frontend/widgets/boton_agregar.dart';
import 'package:frontend/widgets/string_field.dart';
import 'package:frontend/widgets/password_creation_field.dart';

class UserEditForm extends StatefulWidget {
  final User user;
  final Function(String, String, Role, bool) onFormSubmit;

  const UserEditForm({
    Key? key,
    required this.user,
    required this.onFormSubmit,
  }) : super(key: key);

  @override
  _UserEditFormState createState() => _UserEditFormState();
}

class _UserEditFormState extends State<UserEditForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final List<Role> roles = [Role.adminRole, Role.assistantRole];
  late Role selectedRole;
  late bool isActive;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user.name;
    selectedRole = widget.user.role;
    isActive = widget.user.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StringField(
          controller: TextEditingController(text: widget.user.email),
          hintText: 'Correo Electrónico',
          width: MediaQuery.of(context).size.width * 0.8,
          enabled: false, // Campo no editable
        ),
        SizedBox(height: 20),
        StringField(
          controller: nameController,
          hintText: 'Nombre',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 20),
        PasswordCreationField(
          controller: passwordController,
          hintText: 'Nueva Contraseña',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 20),
        DropdownButton<Role>(
          value: selectedRole,
          dropdownColor: Colors.grey[900],
          style: TextStyle(color: Colors.white),
          items: roles.map((Role role) {
            return DropdownMenuItem<Role>(
              value: role,
              child: Text(
                role.name,
                style: TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (Role? newRole) {
            setState(() {
              selectedRole = newRole!;
            });
          },
        ),
        SizedBox(height: 20),
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
              activeColor: Colors.green,
            ),
            Text(
              'Activo',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 20),
        BotonAgregar(
          onPressed: () {
            widget.onFormSubmit(
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
