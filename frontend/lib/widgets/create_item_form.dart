// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/widgets/string_field.dart';
import 'package:frontend/widgets/password_creation_field.dart';

class CreateItemForm extends StatefulWidget {
  final Function(Item) onFormSubmit;

  const CreateItemForm({Key? key, required this.onFormSubmit})
      : super(key: key);

  @override
  _CreateItemFormState createState() => _CreateItemFormState();
}

class _CreateItemFormState extends State<CreateItemForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  Brand? selectedBrand;
  List<Brand> brands = [
    Brand(id: 1, marca: 'Example Brand A'),
    Brand(id: 2, marca: 'Example Brand B'),
  ];

  List<Category> selectedCategories = [];
  List<Category> categories = [
    Category(
        id: 1, nombre: 'Category A', description: 'Description for Category A'),
    Category(
        id: 2, nombre: 'Category B', description: 'Description for Category B'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StringField(
          controller: nameController,
          hintText: 'Nombre del Item',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 20),
        StringField(
          controller: descriptionController,
          hintText: 'Descripción',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 20),
        StringField(
          controller: linkController,
          hintText: 'Link',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 20),
        StringField(
          controller: serialNumberController,
          hintText: 'Número de Serie',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 20),
        StringField(
          controller: quantityController,
          hintText: 'Cantidad',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 20),
        DropdownButton<Brand>(
          value: selectedBrand,
          hint: Text("Selecciona una Marca",
              style: TextStyle(color: Colors.white)),
          dropdownColor: Colors.grey[900],
          style: TextStyle(color: Colors.white),
          items: brands.map((Brand brand) {
            return DropdownMenuItem<Brand>(
              value: brand,
              child: Text(brand.marca),
            );
          }).toList(),
          onChanged: (Brand? newBrand) {
            setState(() {
              selectedBrand = newBrand;
            });
          },
        ),
        SizedBox(height: 20),
        DropdownButton<Category>(
          hint: Text("Selecciona Categorías",
              style: TextStyle(color: Colors.white)),
          dropdownColor: Colors.grey[900],
          style: TextStyle(color: Colors.white),
          items: categories.map((Category category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Text(category.nombre),
            );
          }).toList(),
          onChanged: (Category? newCategory) {
            setState(() {
              if (newCategory != null &&
                  !selectedCategories.contains(newCategory)) {
                selectedCategories.add(newCategory);
              }
            });
          },
        ),
        SizedBox(height: 20),
        Wrap(
          spacing: 10,
          children: selectedCategories.map((category) {
            return Chip(
              label: Text(category.nombre),
              onDeleted: () {
                setState(() {
                  selectedCategories.remove(category);
                });
              },
            );
          }).toList(),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Item newItem = Item(
              id: DateTime.now().millisecondsSinceEpoch,
              nombre: nameController.text,
              description: descriptionController.text,
              link: linkController.text,
              serialNumber: serialNumberController.text,
              quantity: int.parse(quantityController.text),
              marca: selectedBrand!,
              categories: selectedCategories,
            );
            widget.onFormSubmit(newItem);
          },
          child: Text('Crear Item'),
        ),
      ],
    );
  }
}
