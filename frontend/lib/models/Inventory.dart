import 'dart:convert';
import 'item.dart';
import 'Session.dart';
import 'package:dio/dio.dart';

class Inventory {
  static var manager = SessionManager();
  var session = SessionManager.session;
  var user;
  var requestHandler;

  Inventory() {
    user = session.user;
    requestHandler = session.requestHandler;
  }

  Future<List<Brand>> getBrands() async {
    if (!await isReady()) {
      return [];
    }

    var response;
    try {
      response = await requestHandler.getRequest('/item/list/brands/');
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      return [];
    }

    List<Brand> brandList = [];
    for (var brandData in response.data['results']) {
      var brand = Brand.fromJson(brandData);
      brandList.add(brand);
    }

    return brandList;
  }

  Future<List<Category>> getCategories() async {
    if (!await isReady()) {
      return [];
    }

    var response;
    try {
      response = await requestHandler.getRequest('/item/list/categories/');
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      return [];
    }

    List<Category> categoryList = [];
    for (var categoryData in response.data['results']) {
      var category = Category.fromJson(categoryData);
      categoryList.add(category);
    }

    return categoryList;
  }

  Future<List<Item>> getItems({
    List<int>? categoryIds,
    int? brandId,
    String? namePattern,
  }) async {
    if (!await isReady()) {
      return [];
    }



    var queryParameters = {
      if (categoryIds != null) 'categories': categoryIds.join(','),
      if (brandId != null) 'marca': brandId.toString(),
      if (namePattern != null) 'name': namePattern,
    };

    var response;
    try {
      response = await requestHandler.getRequest('/item/list/items/', query: queryParameters);
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      return [];
    }

    List<Item> itemList = [];
    for (var itemData in response.data) {
      var item = Item.fromJson(itemData);
      itemList.add(item);
    }

    return itemList;
  }


  Future<void> createBrand(Brand brand) async {
    if (!await isReady()) {
      return;
    }
    if (!await sessionCheck()) {
      return;
    }

    try {
      var response = await requestHandler.postRequest('/item/brands/', body: brand.toJson());
      manager.notification(notification: 'Marca creada con éxito');
    } on DioException catch (e) {
      manager.errorNotification(error: 'Creación de marca fallida', details: e.response?.data);
    }
  }

  Future<void> createCategory(Category category) async {
    if (!await isReady()) {
      return;
    }
    if (!await sessionCheck()) {
      return;
    }

    try {
      var response = await requestHandler.postRequest('/item/categories/', body: category.toJson());
      manager.notification(notification: 'Categoría creada con éxito');
    } on DioException catch (e) {
      manager.errorNotification(error: 'Creación de categoría fallida', details: e.response?.data);
    }
  }

  Future<void> createItem(Item item) async {
    if (!await isReady()) {
      return;
    }
    if (!await sessionCheck()) {
      return;
    }

    try {
      var response = await requestHandler.postRequest('/item/items/', body: item.toJson());
      manager.notification(notification: 'Ítem creado con éxito');
    } on DioException catch (e) {
      manager.errorNotification(error: 'Creación de ítem fallida', details: e.response?.data);
    }
  }

  Future<void> updateItem(Item item, Item newItem) async {
    if (!await isReady()) {
      return;
    }
    if (!await sessionCheck()) {
      return;
    }

    try {
      var response = await requestHandler.putRequest('/item/items/${item.id}/', body: newItem.toJson());
      item.updateItem(newItem);
      manager.notification(notification: 'Ítem actualizado con éxito');
    } on DioException catch (e) {
      manager.errorNotification(error: 'Actualización de ítem fallida', details: e.response?.data);
    }
  }

  Future<void> deleteItem(Item item) async {
    if (!await isReady()) {
      return;
    }
    if (!await sessionCheck()) {
      return;
    }

    try {
      var response = await requestHandler.deleteRequest('/item/items/${item.id}/');
      manager.notification(notification: 'Ítem eliminado con éxito');
    } on DioException catch (e) {
      manager.errorNotification(error: 'Eliminación de ítem fallida', details: e.response?.data);
    }
  }

  Future<void> deleteBrand(Brand brand) async {
    if (!await isReady()) {
      return;
    }
    if (!await sessionCheck()) {
      return;
    }

    try {
      var response = await requestHandler.deleteRequest('/item/brands/${brand.id}/');
      manager.notification(notification: 'Marca eliminada con éxito');
    } on DioException catch (e) {
      manager.errorNotification(error: 'Eliminación de marca fallida', details: e.response?.data);
    }
  }

  Future<void> deleteCategory(Category category) async {
    if (!await isReady()) {
      return;
    }
    if (!await sessionCheck()) {
      return;
    }

    try {
      var response = await requestHandler.deleteRequest('/item/categories/${category.id}/');
      manager.notification(notification: 'Categoría eliminada con éxito');
    } on DioException catch (e) {
      manager.errorNotification(error: 'Eliminación de categoría fallida', details: e.response?.data);
    }
  }

  Future<Brand> getBrandById(int id) async {
    if (!await isReady()) {
      throw Exception('Not ready');
    }
    if (!await sessionCheck()) {
      throw Exception('Session check failed');
    }

    try {
      var response = await requestHandler.getRequest('/item/brands/$id/');
      return Brand.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      throw Exception('Failed to load brand');
    }
  }

  Future<Category> getCategoryById(int id) async {
    if (!await isReady()) {
      throw Exception('Not ready');
    }
    if (!await sessionCheck()) {
      throw Exception('Session check failed');
    }

    try {
      var response = await requestHandler.getRequest('/item/categories/$id/');
      return Category.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      throw Exception('Failed to load category');
    }
  }

  Future<Item> getItemById(int id) async {
    if (!await isReady()) {
      throw Exception('Not ready');
    }
    if (!await sessionCheck()) {
      throw Exception('Session check failed');
    }

    try {
      var response = await requestHandler.getRequest('/item/items/$id/');
      return Item.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      throw Exception('Failed to load item');
    }
  }

  Future<bool> isReady() async {
    return await session.isReady();
  }

  sessionCheck() {
    return session.sessionCheck();
  }
}
