import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/widgets/icon_button.dart';
import 'package:frontend/widgets/string_field.dart';
import 'package:file_picker/file_picker.dart';

import 'banner.dart';
import 'dart:typed_data' as DartData;
class CreateItemForm extends StatefulWidget {
  final Function(Item, DartData.Uint8List?) onFormSubmit;

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
  List<Category> selectedCategories = [];
  DartData.Uint8List? imageBytes = null;
  DartData.Uint8List? placeHolderBytes = null;

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
            BannerWidget(
              imageUrl: imageBytes != null? imageBytes! : placeHolderBytes!,
              title: "Crear Nuevo Item",
              subtitle: "Complete el formulario para crear un nuevo item",
              description:
              "Ingrese los datos del nuevo item en el laboratorio.",
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    SizedBox(height: 20),
                    StringField(
                      controller: nameController,
                      hintText: 'Nombre del Item',
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    SizedBox(height: 20),
                    StringField(
                      controller: descriptionController,
                      hintText: 'Descripción',
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    SizedBox(height: 20),
                    StringField(
                      controller: linkController,
                      hintText: 'Link',
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    SizedBox(height: 20),
                    StringField(
                      controller: serialNumberController,
                      hintText: 'Número de Serie',
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    SizedBox(height: 20),
                    StringField(
                      controller: quantityController,
                      hintText: 'Cantidad',
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    SizedBox(height: 20),
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
                            );
                          }
                        );
                      }
                    ),

                    SizedBox(height: 20),
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
                              ],
                            );
                          }
                        );
                      }
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
                          quantityOnLoan: 0,
                          marca: selectedBrand!,
                          categories: selectedCategories,
                        );
                        widget.onFormSubmit(newItem, imageBytes);
                      },
                      child: Text('Crear Item'),
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
