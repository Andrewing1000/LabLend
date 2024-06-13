import 'package:flutter/material.dart';
import 'package:frontend/models/Item.dart';
import 'package:frontend/widgets/string_field.dart';

class EditItemForm extends StatefulWidget {
  final Item item;
  final Function(Item) onFormSubmit;

  const EditItemForm({
    super.key,
    required this.item,
    required this.onFormSubmit,
  });

  @override
  _EditItemFormState createState() => _EditItemFormState();
}

class _EditItemFormState extends State<EditItemForm> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController linkController;
  late TextEditingController serialNumberController;
  late TextEditingController quantityController;

  late Brand selectedBrand;
  late List<Category> selectedCategories;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item.nombre);
    descriptionController =
        TextEditingController(text: widget.item.description);
    linkController = TextEditingController(text: widget.item.link);
    serialNumberController =
        TextEditingController(text: widget.item.serialNumber);
    quantityController =
        TextEditingController(text: widget.item.quantity.toString());

    selectedBrand = widget.item.marca;
    selectedCategories = widget.item.categories;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StringField(
          controller: nameController,
          hintText: 'Nombre del Item',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        const SizedBox(height: 20),
        StringField(
          controller: descriptionController,
          hintText: 'Descripción',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        const SizedBox(height: 20),
        StringField(
          controller: linkController,
          hintText: 'Link',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        const SizedBox(height: 20),
        StringField(
          controller: serialNumberController,
          hintText: 'Número de Serie',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        const SizedBox(height: 20),
        StringField(
          controller: quantityController,
          hintText: 'Cantidad',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        const SizedBox(height: 20),
        DropdownButton<Brand>(
          value: selectedBrand,
          hint: const Text("Selecciona una Marca",
              style: TextStyle(color: Colors.white)),
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          items: [
            Brand(id: 1, marca: 'Example Brand A'),
            Brand(id: 2, marca: 'Example Brand B'),
          ].map((Brand brand) {
            return DropdownMenuItem<Brand>(
              value: brand,
              child: Text(brand.marca),
            );
          }).toList(),
          onChanged: (Brand? newBrand) {
            setState(() {
              if (newBrand != null) {
                selectedBrand = newBrand;
              }
            });
          },
        ),
        const SizedBox(height: 20),
        DropdownButton<Category>(
          hint: const Text("Selecciona Categorías",
              style: TextStyle(color: Colors.white)),
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          items: [
            Category(
                id: 1,
                nombre: 'Category A',
                description: 'Description for Category A'),
            Category(
                id: 2,
                nombre: 'Category B',
                description: 'Description for Category B'),
          ].map((Category category) {
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
        const SizedBox(height: 20),
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
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Item newItem = Item(
              id: widget.item.id,
              nombre: nameController.text,
              description: descriptionController.text,
              link: linkController.text,
              serialNumber: serialNumberController.text,
              quantity: int.parse(quantityController.text),
              quantityOnLoan: 2,
              marca: selectedBrand,
              categories: selectedCategories,
            );
            widget.onFormSubmit(newItem);
          },
          child: const Text('Actualizar Item'),
        ),
      ],
    );
  }
}
