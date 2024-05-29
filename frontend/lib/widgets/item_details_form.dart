import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/widgets/string_field.dart';

class ItemDetailsForm extends StatefulWidget {
  final Item item;

  const ItemDetailsForm({Key? key, required this.item}) : super(key: key);

  @override
  _ItemDetailsFormState createState() => _ItemDetailsFormState();
}

class _ItemDetailsFormState extends State<ItemDetailsForm> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController linkController;
  late TextEditingController serialNumberController;
  late TextEditingController quantityController;
  Brand? selectedBrand;
  List<Category> selectedCategories = [];

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
          items: [selectedBrand!].map((Brand brand) {
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
      ],
    );
  }
}
