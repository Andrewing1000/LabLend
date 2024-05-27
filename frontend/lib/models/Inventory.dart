import 'dart:convert';

import 'Item.dart';
import 'Session.dart';

class Inventory {
  get manager => SessionManager();
  get session => manager.session;
  get user => session.user;
  get requestHandler => session.requestHandler;

  List<Item> inventory = [];

  Future<List<Brand>> getBrands() async {
    try {
      final response = await requestHandler.getRequest('/api/brands/');
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.data);
        return data.map((json) => Brand.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load brands');
      }
    } catch (e) {
      print('Error fetching brands: $e');
      throw e;
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await requestHandler.getRequest('/api/categories/');
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.data);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      throw e;
    }
  }

  Future<List<Item>> getItems({
    List<int>? categoryIds,
    int? brandId,
    String? namePattern,
  }) async {
    try {
      final queryParameters = {
        if (categoryIds != null) 'categories': categoryIds.join(','),
        if (brandId != null) 'brand': brandId.toString(),
        if (namePattern != null) 'name': namePattern,
      };

      final response = await requestHandler.getRequest('/api/items/', query: queryParameters);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.data);
        return data.map((json) => Item.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      print('Error fetching items: $e');
      throw e;
    }
  }

  Future<void> createBrand(Brand brand) async {
    try {
      final response = await requestHandler.postRequest('/api/brands/', body: brand.toJson());
      if (response.statusCode != 201) {
        throw Exception('Failed to create brand');
      }
    } catch (e) {
      print('Error creating brand: $e');
      throw e;
    }
  }

  Future<void> createCategory(Category category) async {
    try {
      final response = await requestHandler.postRequest('/api/categories/', body: category.toJson());
      if (response.statusCode != 201) {
        throw Exception('Failed to create category');
      }
    } catch (e) {
      print('Error creating category: $e');
      throw e;
    }
  }

  Future<void> createItem(Item item) async {
    try {
      final response = await requestHandler.postRequest('/api/items/', body: item.toJson());
      if (response.statusCode != 201) {
        throw Exception('Failed to create item');
      }
    } catch (e) {
      print('Error creating item: $e');
      throw e;
    }
  }

  Future<void> updateItem(Item item, Item newItem) async {
    try {
      final response = await requestHandler.putRequest('/api/items/${item.id}/', body: newItem.toJson());
      item.updateItem(newItem);
      if (response.statusCode != 200) {
        throw Exception('Failed to update item');
      }
    } catch (e) {
      print('Error updating item: $e');
      throw e;
    }
  }

  Future<void> deleteItem(Item item) async {
    try {
      final response = await requestHandler.deleteRequest('/api/items/${item.id}/');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      print('Error deleting item: $e');
      throw e;
    }
  }

  Future<void> deleteBrand(Brand brand) async {
    try {
      final response = await requestHandler.deleteRequest('/api/brands/${brand.id}/');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete brand');
      }
    } catch (e) {
      print('Error deleting brand: $e');
      throw e;
    }
  }

  Future<void> deleteCategory(Category category) async {
    try {
      final response = await requestHandler.deleteRequest('/api/categories/${category.id}/');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete category');
      }
    } catch (e) {
      print('Error deleting category: $e');
      throw e;
    }
  }


  Future<Brand> getBrandById(int id) async {
    try {
      final response = await requestHandler.getRequest('/api/brands/$id/');
      if (response.statusCode == 200) {
        return Brand.fromJson(json.decode(response.data));
      } else {
        throw Exception('Failed to load brand');
      }
    } catch (e) {
      print('Error fetching brand: $e');
      throw e;
    }
  }

  Future<Category> getCategoryById(int id) async {
    try {
      final response = await requestHandler.getRequest('/api/categories/$id/');
      if (response.statusCode == 200) {
        return Category.fromJson(json.decode(response.data));
      } else {
        throw Exception('Failed to load category');
      }
    } catch (e) {
      print('Error fetching category: $e');
      throw e;
    }
  }

  Future<Item> getItemById(int id) async {
    try {
      final response = await requestHandler.getRequest('/api/items/$id/');
      if (response.statusCode == 200) {
        return Item.fromJson(json.decode(response.data));
      } else {
        throw Exception('Failed to load item');
      }
    } catch (e) {
      print('Error fetching item: $e');
      throw e;
    }
  }
}
