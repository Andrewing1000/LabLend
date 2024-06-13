import 'package:flutter/material.dart';
import 'package:frontend/models/Item.dart';
import 'package:frontend/models/Session.dart';

class CategoryBrandForm extends StatefulWidget {
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
  }

  Future<void> _deleteBrand() async {
    if (_selectedBrand != null) {
      await SessionManager.inventory.deleteBrand(_selectedBrand!);
      _loadBrands(); // Refresh brands
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
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: const Color(0xFF121212), // Spotify dark background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crear Categoría',
                style: TextStyle(fontSize: 20, color: Colors.white)),
            TextField(
              controller: _categoryNameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la Categoría',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _categoryDescriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createCategory,
              child: Text('Crear Categoría'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            ),
            SizedBox(height: 20),
            Text('Crear Marca',
                style: TextStyle(fontSize: 20, color: Colors.white)),
            TextField(
              controller: _brandNameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la Marca',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createBrand,
              child: Text('Crear Marca'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            ),
            SizedBox(height: 20),
            Text('Eliminar Categoría',
                style: TextStyle(fontSize: 20, color: Colors.white)),
            DropdownButton<Category>(
              value: _selectedCategory,
              hint: Text('Seleccionar Categoría',
                  style: TextStyle(color: Colors.white70)),
              dropdownColor: const Color(0xFF2E2E2E),
              onChanged: (Category? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: _categories.map((Category category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.nombre,
                      style: TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _deleteCategory,
              child: Text('Eliminar Categoría'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            ),
            SizedBox(height: 20),
            Text('Eliminar Marca',
                style: TextStyle(fontSize: 20, color: Colors.white)),
            DropdownButton<Brand>(
              value: _selectedBrand,
              hint: Text('Seleccionar Marca',
                  style: TextStyle(color: Colors.white70)),
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
                      Text(brand.marca, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _deleteBrand,
              child: Text('Eliminar Marca'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
