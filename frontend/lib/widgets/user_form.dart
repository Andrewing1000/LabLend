import 'package:flutter/material.dart';
// import 'package:frontend/models/user.dart'; // Comentado para ver solo la vista
import 'package:frontend/widgets/boton_agregar.dart';
import 'package:frontend/widgets/string_field.dart';
import 'package:frontend/widgets/password_creation_field.dart';

import '../models/User.dart';

class UserForm extends StatefulWidget {
  final Function(String, String, String, Role, bool) onFormSubmit;

  const UserForm({
    Key? key,
    required this.onFormSubmit,
  }) : super(key: key);

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final List<Role> roles = [Role.adminRole, Role.assistantRole]; // Comentado para ver solo la vista
  Role selectedRole = Role.assistantRole; // Comentado para ver solo la vista
  bool isActive = true;


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StringField(
          controller: emailController,
          hintText: 'Correo Electrónico',
          width: MediaQuery.of(context).size.width * 0.8,
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
          hintText: 'Contraseña',
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
              emailController.text,
              nameController.text,
              passwordController.text,
              selectedRole, // Comentado para ver solo la vista
              isActive,
            );
          },
        ),
      ],
    );
  }
}
