import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/widgets/string_field.dart';
import 'package:frontend/widgets/password_creation_field.dart';

class ItemDetailsForm extends StatefulWidget {
  final Item item;

  const ItemDetailsForm({Key? key, required this.item}) : super(key: key);

  @override
  _ItemDetailsFormState createState() => _ItemDetailsFormState();
}

class _ItemDetailsFormState extends State<ItemDetailsForm> {
  late TextEditingController _nombreController;
  late TextEditingController _descriptionController;
  late TextEditingController _linkController;
  late TextEditingController _serialNumberController;
  late TextEditingController _quantityController;
  late TextEditingController _marcaController;
  late TextEditingController _categoriesController;
  late TextEditingController _idController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.item.nombre);
    _descriptionController =
        TextEditingController(text: widget.item.description);
    _linkController = TextEditingController(text: widget.item.link);
    _serialNumberController =
        TextEditingController(text: widget.item.serialNumber);
    _quantityController =
        TextEditingController(text: widget.item.quantity.toString());
    _marcaController = TextEditingController(text: widget.item.marca.marca);
    _categoriesController = TextEditingController(
      text: widget.item.categories.map((c) => c.nombre).join(', '),
    );
    _idController = TextEditingController(text: widget.item.id.toString());
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _serialNumberController.dispose();
    _quantityController.dispose();
    _marcaController.dispose();
    _categoriesController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _updateItem() {
    // Actualiza los campos del ítem
    widget.item.update(Item(
      id: widget.item.id,
      nombre: _nombreController.text,
      description: _descriptionController.text,
      link: _linkController.text,
      serialNumber: _serialNumberController.text,
      quantity: int.parse(_quantityController.text),
      marca: Brand(id: widget.item.marca.id, marca: _marcaController.text),
      categories: widget.item.categories, // No cambiamos las categorías aquí
    ));
    // Aquí puedes llamar a una función para actualizar el ítem en el servidor si es necesario
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StringField(
          controller: _idController,
          hintText: 'ID',
          width: MediaQuery.of(context).size.width * 0.8,
          enabled: false, // El ID no se puede editar
        ),
        SizedBox(height: 10),
        StringField(
          controller: _nombreController,
          hintText: 'Nombre del Ítem',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 10),
        StringField(
          controller: _descriptionController,
          hintText: 'Descripción',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 10),
        StringField(
          controller: _linkController,
          hintText: 'Enlace',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 10),
        StringField(
          controller: _serialNumberController,
          hintText: 'Número de Serie',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 10),
        StringField(
          controller: _quantityController,
          hintText: 'Cantidad',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 10),
        StringField(
          controller: _marcaController,
          hintText: 'Marca',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 10),
        StringField(
          controller: _categoriesController,
          hintText: 'Categorías',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _updateItem,
          child: Text('Actualizar Ítem'),
        ),
      ],
    );
  }
}
