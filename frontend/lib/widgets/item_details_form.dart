import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/widgets/icon_button.dart';
import 'package:frontend/widgets/string_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

import 'dart:typed_data' as DartData;

class UpdateItemForm extends StatefulWidget {
  final Item item;
  final Function(Item, DartData.Uint8List?) onFormSubmit;

  const   UpdateItemForm({
    super.key,
    required this.item,
    required this.onFormSubmit,
  });

  @override
  _UpdateItemFormState createState() => _UpdateItemFormState(item: item);
}

class _UpdateItemFormState extends State<UpdateItemForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  Brand? selectedBrand;
  List<Category> selectedCategories = [];
  DartData.Uint8List? imageBytes;
  DartData.Uint8List? placeHolderBytes;
  late Item item;
  late Item newItem;

  _UpdateItemFormState({required this.item}) : newItem = item.clone();

  @override
  void initState() {
    super.initState();
    newItem = widget.item.clone();
    nameController.text = newItem.nombre;
    descriptionController.text = newItem.description ?? '';
    linkController.text = newItem.link ?? '';
    serialNumberController.text = newItem.serialNumber ?? '';
    quantityController.text = newItem.quantity.toString();
    _loadImageBytes();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    serialNumberController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadImageBytes() async {
    try {
      final ByteData data = await rootBundle.load(
          'assets/images/place_holder.png');
      placeHolderBytes = data.buffer.asUint8List();

      if (newItem.imagePath != null) {
        final response = await Dio().get(
          newItem.imagePath!,
          options: Options(responseType: ResponseType.bytes),
        );

        if (response.statusCode == 200) {
          placeHolderBytes = Uint8List.fromList(response.data);
        }
      }
    } catch (e) {
      imageBytes = placeHolderBytes;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load image: $e")),
      );
    }
  }

  Future<List<Brand>> _fetchBrands() async {
    try {
      return await SessionManager.inventory.getBrands();
    } catch (e) {
      throw Exception("Failed to fetch brands");
    }
  }

  Future<List<Category>> _fetchCategories() async {
    try {
      return await SessionManager.inventory.getCategories();
    } catch (e) {
      throw Exception("Failed to fetch categories");
    }
  }

  void _submitForm() {
    if (nameController.text.isNotEmpty) {
      newItem.nombre = nameController.text;
    }
    if (descriptionController.text.isNotEmpty) {
      newItem.description = descriptionController.text;
    }
    if (linkController.text.isNotEmpty) {
      newItem.link = linkController.text;
    }
    if (serialNumberController.text.isNotEmpty) {
      newItem.serialNumber = serialNumberController.text;
    }
    if (quantityController.text.isNotEmpty) {
      newItem.quantity = int.parse(quantityController.text);
    }

    if (selectedBrand?.id != newItem.marca.id) {
      newItem.marca = selectedBrand ?? newItem.marca;
    }

    newItem.categories = selectedCategories;

    widget.onFormSubmit(newItem, imageBytes);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadImageBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildTextField(nameController, "Nombre", newItem.nombre),
                    _buildTextField(descriptionController, "Descripción",
                        newItem.description),
                    _buildTextField(linkController, "Link", newItem.link),
                    _buildTextField(serialNumberController, "Número de Serie",
                        newItem.serialNumber),
                    _buildTextField(quantityController, "Cantidad",
                        newItem.quantity.toString()),
                    const SizedBox(height: 20),
                    _buildBrandDropdown(),
                    const SizedBox(height: 20),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Editar Item'),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.memory(
                                imageBytes ?? placeHolderBytes!,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconButton(
                                  iconNormal: Icons.upload,
                                  iconSelected: Icons.clear,
                                  isSelected: imageBytes != null,
                                  onPressed: () async {
                                    if (imageBytes != null) {
                                      setState(() {
                                        imageBytes = null;
                                      });
                                    }

                                    FilePickerResult? file = await FilePicker
                                        .platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['jpg', 'jpeg', 'png'],
                                    );

                                    if (file != null) {
                                      setState(() {
                                        imageBytes = file.files.single.bytes;
                                      });
                                    }
                                  },
                                  size: 30,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String? initialValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: StringField(
        required: false,
        controller: controller,
        hintText: initialValue ?? '',
        width: MediaQuery
            .of(context)
            .size
            .width * 0.4,
      ),
    );
  }

  Widget _buildBrandDropdown() {
    return FutureBuilder<List<Brand>>(
      future: _fetchBrands(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        } else
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Container();
        }

        List<Brand> brands = snapshot.data!;
        selectedBrand = null;
        for(Brand brand in brands){
          if(brand.id == newItem.marca.id){
            selectedBrand = brand;
          }
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return DropdownButton<Brand>(
              value: selectedBrand,
              hint: const Text(
                  "Selecciona una Marca", style: TextStyle(color: Colors.white)),
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              items: brands.map((Brand brand) {
                return DropdownMenuItem<Brand>(
                  value: brand,
                  child: Text(brand.marca),
                );
              }).toList(),
              onChanged: (Brand? newBrand) {
                setState(() {
                  selectedBrand = newBrand;
                  if (selectedBrand != null) {
                    newItem.marca = selectedBrand!;
                  }
                });
              },
            );
          }
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return FutureBuilder<List<Category>>(
      future: _fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Container();
        }

        List<Category> categories = snapshot.data!;
        selectedCategories = categories.where((cat) {
          return newItem.categories.any((catI) => catI.id == cat.id);
        }).toList();

        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                DropdownButton<Category>(
                  hint: const Text("Selecciona Categorías", style: TextStyle(color: Colors.white)),
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white),
                  items: categories.map((Category category) {
                    return DropdownMenuItem<Category>(
                      value: category,
                      child: Text(category.nombre),
                    );
                  }).toList(),
                  onChanged: (Category? newCategory) {
                    setState(() {
                      if (newCategory != null && !selectedCategories.contains(newCategory)) {
                        selectedCategories.add(newCategory);
                        newItem.categories.add(newCategory);
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
                          newItem.categories.remove(category);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            );
          }
        );
      },
    );
  }
}