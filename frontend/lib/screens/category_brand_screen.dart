import 'package:flutter/material.dart';
import 'package:frontend/widgets/category_brand_form.dart';

class CategoryBrandScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Categorías y Marcas'),
      ),
      body: CategoryBrandForm(),
    );
  }
}
