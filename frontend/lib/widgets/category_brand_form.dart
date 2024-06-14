import 'package:flutter/material.dart';
import 'package:frontend/models/Item.dart';
import 'package:frontend/models/Session.dart';

class CategoryBrandForm extends StatefulWidget {
  const CategoryBrandForm({super.key});

  @override
  _CategoryBrandFormState createState() => _CategoryBrandFormState();
}

class _CategoryBrandFormState extends State<CategoryBrandForm> {
  final _categoryNameController = TextEditingController();
  final _categoryDescriptionController = TextEditingController();
  final _brandNameController = TextEditingController();

  List<Category> _categories = [];
  List<Brand> _brands = [];

  Category? _selectedCategory;
  Brand? _selectedBrand;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadBrands();
  }

  Future<void> _loadCategories() async {
    var categories = await SessionManager.inventory.getCategories();
    setState(() {
      _categories = categories;
      if (_selectedCategory != null &&
          !_categories.contains(_selectedCategory)) {
        _selectedCategory = null;
      }
    });
  }

  Future<void> _loadBrands() async {
    var brands = await SessionManager.inventory.getBrands();
    setState(() {
      _brands = brands;
      if (_selectedBrand != null && !_brands.contains(_selectedBrand)) {
        _selectedBrand = null;
      }
    });
  }

  Future<void> _createCategory() async {
    final category = Category(
      id: 0,
      nombre: _categoryNameController.text,
      description: _categoryDescriptionController.text,
    );
    await SessionManager.inventory.createCategory(category);
    _loadCategories(); // Refresh categories
  }

  Future<void> _createBrand() async {
    final brand = Brand(
      id: 0,
      marca: _brandNameController.text,
    );
    await SessionManager.inventory.createBrand(brand);
    _loadBrands(); // Refresh brands
  }

  Future<void> _deleteCategory() async {
    if (_selectedCategory != null) {
      await SessionManager.inventory.deleteCategory(_selectedCategory!);
      _loadCategories(); // Refresh categories
    }
    else{
      SessionManager().errorNotification(error: "Debe seleccionar una categoría");
    }
  }

  Future<void> _deleteBrand() async {
    if (_selectedBrand != null) {
      await SessionManager.inventory.deleteBrand(_selectedBrand!);
      _loadBrands(); // Refresh brands
    }
    else{
      SessionManager().errorNotification(error: "Debe seleccionar una marca");
    }
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _categoryDescriptionController.dispose();
    _brandNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(10),
      ),// Spotify dark background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [

          const SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 300,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _categoryNameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la Categoría',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: const OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _categoryDescriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: const OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _createCategory,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      child: const Text('Crear Categoría'),
                    ),

                  ],
                ),
              ),

              const SizedBox(width: 100),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 300
                ),
                child: Column(
                  children: [
                    DropdownButton<Category>(
                      value: _selectedCategory,
                      hint: Text('Seleccionar Categoría',
                        style: Theme.of(context).textTheme.labelMedium,),
                      dropdownColor: const Color(0xFF2E2E2E),
                      onChanged: (Category? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      items: _categories.map((Category category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.nombre, style: Theme.of(context).textTheme.bodyMedium,),
                        );
                      }).toList(),
                    ),
                    ElevatedButton(
                      onPressed: _deleteCategory,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      child: const Text('Eliminar Categoría'),

                    ),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 30,),
          const Divider(
            color: Colors.white, // Custom color
            height: 10, // Space around the divider
            thickness: 1, // Thickness of the line
            indent: 0, // Start margin
            endIndent: 0, // End margin
          ),
          const SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 300,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _brandNameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la Marca',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: const OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _createBrand,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      child: const Text('Crear Marca'),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 100),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: 300
                ),
                child: Column(
                  children: [
                    DropdownButton<Brand>(
                      value: _selectedBrand,
                      hint: Text('Seleccionar Marca',
                          style: Theme.of(context).textTheme.labelMedium
                      ),
                      dropdownColor: const Color(0xFF2E2E2E),
                      onChanged: (Brand? newValue) {
                        setState(() {
                          _selectedBrand = newValue;
                        });
                      },
                      items: _brands.map((Brand brand) {
                        return DropdownMenuItem<Brand>(
                          value: brand,
                          child:
                          Text(brand.marca, style: Theme.of(context).textTheme.bodyMedium),
                        );
                      }).toList(),
                    ),
                    ElevatedButton(
                      onPressed: _deleteBrand,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      child: const Text('Eliminar Marca'),
                    ),
                  ],
                ),
              )
            ],
          ),

          Expanded(child: Spacer()),

        ],
      ),
    );
  }
}
