import 'package:flutter/material.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/widgets/category_brand_form.dart';

class CategoryBrandScreen extends PageBase{

  @override
  State<CategoryBrandScreen> createState() {
    return AnState();
  }

  @override
  void onDispose() {
    return;
  }

  @override
  void onSet() {
    return;
  }
}

class AnState extends State<CategoryBrandScreen>{
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Categorías y Marcas'),
      ),
      body: CategoryBrandForm(),
    );
  }
}
