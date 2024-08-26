
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/models/Item.dart';
import 'package:frontend/widgets/icon_button.dart';
import 'package:frontend/widgets/string_field.dart';
import 'package:file_picker/file_picker.dart';

import 'dart:typed_data' as DartData;
class CreateItemForm extends StatefulWidget {
  final Function(
      {
      required String name,
      required String description,
      required String link,
      required String serialNumber,
      required String quantity,
      Brand? brand,
      required List<Category> categories,
      Uint8List? imageBytes,
      }) onFormSubmit;

  const CreateItemForm({super.key, required this.onFormSubmit});

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
  List<Category> selectedCategories = [];
  DartData.Uint8List? imageBytes;
  DartData.Uint8List? placeHolderBytes;

  Future<void> _loadImageBytes() async {
    final DartData.ByteData data = await rootBundle.load('assets/images/place_holder.png');
    placeHolderBytes = data.buffer.asUint8List();
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadImageBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white,));
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
                    StringField(
                      controller: nameController,
                      hintText: '',
                      labelText: 'Nombre del Item',
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    const SizedBox(height: 20),
                    StringField(
                      controller: descriptionController,
                      hintText: '',
                      labelText: 'Descripción',
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    const SizedBox(height: 20),
                    StringField(
                      required: false,
                      controller: linkController,
                      hintText: '',
                      labelText: 'Link',
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    const SizedBox(height: 20),
                    StringField(
                      controller: serialNumberController,
                      hintText: '',
                      labelText: 'Código de Serie',
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    const SizedBox(height: 20),
                    StringField(
                      controller: quantityController,
                      hintText: '',
                      labelText: 'Cantidad',
                      digitsOnly: true,
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<List<Brand>>(
                      future: SessionManager.inventory.getBrands(),
                      builder: (context, AsyncSnapshot<List<Brand>> snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return const Center(child: CircularProgressIndicator(color: Colors.white,),);
                        }
                        else if(!snapshot.hasData || snapshot.data!.isEmpty){
                          return Container();
                        }
                        else if(snapshot.hasError){
                          return Container();
                        }

                        selectedBrand = null;
                        List<Brand> brands = snapshot.data!;

                        return StatefulBuilder(
                          builder: (context, setState) {
                            return DropdownButton<Brand>(
                              value: selectedBrand,
                              hint: const Text("Selecciona una Marca",
                                  style: TextStyle(color: Colors.white)),
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
                                });
                              },
                            );
                          }
                        );
                      }
                    ),

                    const SizedBox(height: 20),
                    FutureBuilder<List<Category>>(
                      future: SessionManager.inventory.getCategories(),
                      builder: (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return const Center(child: CircularProgressIndicator(color: Colors.white,),);
                        }
                        else if(!snapshot.hasData || snapshot.data!.isEmpty){
                          return Container();
                        }
                        else if(snapshot.hasError){
                          return Container();
                        }
                        List<Category> categories = snapshot.data!;
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return Column(
                              children: [
                                DropdownButton<Category>(
                                  hint: const Text("Selecciona Categorías",
                                      style: TextStyle(color: Colors.white)),
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
                                      backgroundColor: Colors.white,
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
                        );
                      }
                    ),


                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        widget.onFormSubmit(
                            name: nameController.text,
                            description: descriptionController.text,
                            link: linkController.text,
                            serialNumber: serialNumberController.text,
                            quantity: quantityController.text,
                            brand: selectedBrand,
                            categories: selectedCategories,
                            imageBytes: imageBytes);
                      },
                      child: const Text('Crear Item'),
                    ),
                  ],
                ),

                Expanded(
                  child: Center(
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                clipBehavior: Clip.hardEdge,
                                borderRadius: BorderRadius.circular(20),
                                child:
                                Image.memory(
                                  imageBytes!=null? imageBytes!:placeHolderBytes!,
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
                                      onPressed: () async{
                                        if(imageBytes!=null){
                                          setState(() {
                                            imageBytes = null;
                                          });
                                        }

                                        FilePickerResult? file = await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['jpg', 'jpeg', 'png'],
                                        );

                                        if(file != null){
                                          setState(() {
                                            imageBytes = file.files.single.bytes;
                                          });
                                        }
                                      },
                                      size: 30)
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                  ),
                )
              ],
            ),
          ],
        );
      }
    );
  }
}
