// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:frontend/models/Loan.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/widgets/string_field.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  Loan ? myLoan;

  @override
  Widget build(BuildContext context) {
    SessionManager ? session; 

    



    final TextEditingController loanController = TextEditingController();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Agregue nuevo Item"),
        Container(
          height: 39,
        ),
        StringField(
          controller: loanController,
          hintText: "Nombre Item",
          width: 600,
        ),
        Container(
          height: 10,
        ),

      ],
    );
  }
}
