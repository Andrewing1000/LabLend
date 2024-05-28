import 'package:flutter/material.dart';
import 'package:frontend/models/inventory.dart';
import 'package:frontend/models/item.dart';
//import 'package:frontend/models/category.dart';
//import 'package:frontend/models/brand.dart';
import 'package:frontend/widgets/boton_agregar.dart';
import 'package:frontend/widgets/notification.dart';
import 'package:frontend/widgets/banner.dart';

class CreationItemScreen extends StatefulWidget {
  @override
  _CreationItemScreenState createState() => _CreationItemScreenState();
}

class _CreationItemScreenState extends State<CreationItemScreen> {
  final Inventory inventory = Inventory();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  bool _showNotification = false;
  String _notificationMessage = '';

  void _createNewItem() {
    String name = nameController.text;
    String description = descriptionController.text;
    String link = linkController.text;
    String serialNumber = serialNumberController.text;
    int quantity = int.tryParse(quantityController.text) ?? 0;
    String brandName = brandController.text;
    String categoryName = categoryController.text;

    if (name.isEmpty ||
        description.isEmpty ||
        link.isEmpty ||
        serialNumber.isEmpty ||
        quantity == 0 ||
        brandName.isEmpty ||
        categoryName.isEmpty) {
      setState(() {
        _notificationMessage =
            "Todos los campos son obligatorios y la cantidad debe ser mayor que 0.";
        _showNotification = true;
      });
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showNotification = false;
        });
      });
      return;
    }

    /*  Brand brand = Brand(id: 1, marca: brandName);
    Category category = Category(
        id: 1, nombre: categoryName, description: 'Category description');
    List<Category> categories = [category];

    Item newItem = Item(
      id: 1,
      nombre: name,
      description: description,
      link: link,
      serialNumber: serialNumber,
      quantity: quantity,
      marca: brand,
      categories: categories,
    );

    inventory.createItem(name: name);
    newItem.create();*/

    setState(() {
      _notificationMessage = "Item '$name' creado con éxito.";
      _showNotification = true;
    });

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showNotification = false;
      });
    });

    // Clear fields after creation
    nameController.clear();
    descriptionController.clear();
    linkController.clear();
    serialNumberController.clear();
    quantityController.clear();
    brandController.clear();
    categoryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Crear Nuevo Item'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                BannerWidget(
                  imageUrl: "assets/images/place_holder.png",
                  title: "Inventario del Laboratorio de Física",
                  subtitle: "Creacion de items",
                  description: "asdasdaskdlaskd.",
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del Item',
                          filled: true,
                          fillColor: Colors.grey[900],
                          labelStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          filled: true,
                          fillColor: Colors.grey[900],
                          labelStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: linkController,
                        decoration: InputDecoration(
                          labelText: 'Enlace',
                          filled: true,
                          fillColor: Colors.grey[900],
                          labelStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: serialNumberController,
                        decoration: InputDecoration(
                          labelText: 'Número de Serie',
                          filled: true,
                          fillColor: Colors.grey[900],
                          labelStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: quantityController,
                        decoration: InputDecoration(
                          labelText: 'Cantidad',
                          filled: true,
                          fillColor: Colors.grey[900],
                          labelStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: brandController,
                        decoration: InputDecoration(
                          labelText: 'Marca',
                          filled: true,
                          fillColor: Colors.grey[900],
                          labelStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: categoryController,
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          filled: true,
                          fillColor: Colors.grey[900],
                          labelStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      BotonAgregar(
                        onPressed: _createNewItem,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showNotification)
            NotificationWidget(
              message: _notificationMessage,
              //alignment: Alignment.bottomCenter,
            ),
        ],
      ),
    );
  }
}
