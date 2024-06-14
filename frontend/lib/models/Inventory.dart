import 'dart:typed_data';
import 'Item.dart';
import 'Session.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class Inventory {
  static var manager = SessionManager();
  var requestHandler = SessionManager.httpHandler;

  Map<int, Item> _cacheItems = {};

  Future<List<Brand>> getBrands() async {
    if (!await isReady()) {
      return [];
    }

    Response response;
    try {
      response = await requestHandler.getRequest('/item/list/brands/');
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      return [];
    }

    List<Brand> brandList = [];
    for (var brandData in response.data) {
      var brand = Brand.fromJson(brandData);
      brandList.add(brand);
    }

    return brandList;
  }

  Future<List<Category>> getCategories() async {
    if (!await isReady()) {
      return [];
    }

    Response response;
    try {
      response = await requestHandler.getRequest('/item/list/categories/');
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      return [];
    }

    List<Category> categoryList = [];
    for (var categoryData in response.data) {
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
      if (categoryIds != null && categoryIds.isNotEmpty) 'categories' : categoryIds.map((id) => id.toString()).toList(),
      if (brandId != null) 'marca': brandId.toString(),
      if (namePattern != null) 'name': namePattern,
    };

    Response response;
    try {
      response = await requestHandler.getRequest('/item/list/items/', query: queryParameters);
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      return [];
    }


    Map<int, Item> newDict = {};
    for (var itemData in response.data) {
      int itemId = itemData['id'];

      if(_cacheItems.containsKey(itemId)){
        _cacheItems[itemId]!.updateItem(Item.fromJson(itemData));
        newDict[itemId] = _cacheItems[itemId]!;
      }
      else{
        newDict[itemId] = Item.fromJson(itemData);
      }


    }
    _cacheItems = newDict;
    return _cacheItems.values.toList();
  }

  Future<Brand?> createBrand(Brand brand) async {
    if (!await isReady()) {
      return null;
    }
    if (!isAdmin()) {
      return null;
    }
    if (!await sessionCheck()) {
      return null;
    }

    try {
      var response = await requestHandler.postRequest('/item/brands/', body: brand.toJson());
      manager.notification(notification: 'Marca creada con éxito');
      return Brand.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(error: 'Creación de marca fallida', details: e.response?.data);
      return null;
    }
  }

  Future<Category?> createCategory(Category category) async {
    if (!await isReady()) {
      return null;
    }
    if (!isAdmin()) {
      return null;
    }
    if (!await sessionCheck()) {
      return null;
    }

    try {
      var response = await requestHandler.postRequest('/item/categories/', body: category.toJson());
      manager.notification(notification: 'Categoría creada con éxito');
      return Category.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(error: 'Creación de categoría fallida', details: e.response?.data);
      return null;
    }
  }

  Future<Item?> createItem(Item item) async {
    if (!await isReady()) {
      return null;
    }
    if (!isAdmin()) {
      return null;
    }
    if (!await sessionCheck()) {
      return null;
    }

    try {
      var response = await requestHandler.postRequest('/item/items/', body: item.toJson());

      Item newItem = Item.fromJson(response.data);
      item.updateItem(newItem);
      manager.notification(notification: 'Ítem creado con éxito');
      return Item.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(error: 'Creación de ítem fallida', details: e.response?.data);
      return null;
    }
  }


  Future<bool> uploadImage(Item item, Uint8List imageBytes, String fileExtension) async {
    String mimeType;

    switch (fileExtension.toLowerCase()) {
      case 'jpeg':
      case 'jpg':
        mimeType = 'image/jpeg';
        break;
      case 'png':
        mimeType = 'image/png';
        break;
      default:
        throw UnsupportedError('Unsupported file type: $fileExtension');
    }

    FormData formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(
        imageBytes,
        filename: 'upload.$fileExtension',
        contentType: MediaType('image', fileExtension),
      ),
    });


    try {
      final dio = requestHandler.dio;
      final response = await dio.post('/item/items/${item.id}/upload-image/', data: formData);

      if (response.statusCode == 200) {
        manager.notification(notification: 'La imagen se ha subido exitosamente');
        return true;
      } else {
        manager.errorNotification(error: "No se pudo agregar la imagen");
        return false;
      }
    } on DioException catch (e) {
      print(e.stackTrace);
      manager.errorNotification(error: "No se pudo agregar la imagen", details: e.response?.data);
      return false;
    }
  }



  Future<Item?> updateItem(Item item, Item newItem) async {
    if (!await isReady()) {
      return null;
    }
    if (!isAdmin()) {
      return null;
    }
    if (!await sessionCheck()) {
      return null;
    }

    try {
      var data = newItem.toJson();
      data.remove('image');
      var response = await requestHandler.putRequest('/item/items/${item.id}/', body: data);
      item.updateItem(newItem);
      manager.notification(notification: 'Ítem actualizado con éxito');
      return Item.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(error: 'Actualización de ítem fallida', details: e.response?.data);
      return null;
    }
  }

  Future<bool> deleteItem(Item item) async {
    if (!await isReady()) {
      return false;
    }
    if (!isAdmin()) {
      return false;
    }
    if (!await sessionCheck()) {
      return false;
    }

    try {
      await requestHandler.deleteRequest('/item/items/${item.id}/');
      manager.notification(notification: 'Ítem eliminado con éxito');
      return true;
    } on DioException catch (e) {
      manager.errorNotification(error: 'Eliminación de ítem fallida', details: e.response?.data);
      return false;
    }
  }

  Future<bool> deleteBrand(Brand brand) async {
    if (!await isReady()) {
      return false;
    }
    if (!isAdmin()) {
      return false;
    }
    if (!await sessionCheck()) {
      return false;
    }

    try {
      await requestHandler.deleteRequest('/item/brands/${brand.id}/');
      manager.notification(notification: 'Marca eliminada con éxito');
      return true;
    } on DioException catch (e) {
      manager.errorNotification(error: 'Eliminación de marca fallida', details: e.response?.data);
      return false;
    }
  }

  Future<bool> deleteCategory(Category category) async {
    if (!await isReady()) {
      return false;
    }
    if (!isAdmin()) {
      return false;
    }
    if (!await sessionCheck()) {
      return false;
    }

    try {
      await requestHandler.deleteRequest('/item/categories/${category.id}/');
      manager.notification(notification: 'Categoría eliminada con éxito');
      return true;
    } on DioException catch (e) {
      manager.errorNotification(error: 'Eliminación de categoría fallida', details: e.response?.data);
      return false;
    }
  }

  Future<Brand?> getBrandById(int id) async {
    if (!await isReady()) {
      return null;
    }

    try {
      var response = await requestHandler.getRequest('/item/list/brands/$id/');
      return Brand.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      return null;
    }
  }

  Future<Category?> getCategoryById(int id) async {
    if (!await isReady()) {
      return null;
    }

    try {
      var response = await requestHandler.getRequest('/item/list/categories/$id/');
      return Category.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      return null;
    }
  }

  Future<Item?> getItemById(int id) async {
    if (!await isReady()) {
      return null;
    }

    if(_cacheItems.containsKey(id)){
      return _cacheItems[id];
    }

    try {
      var response = await requestHandler.getRequest('/item/list/items/$id/');
      var item = Item.fromJson(response.data);
      _cacheItems[id] = item;
      return item;
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      return null;
    }
  }

  bool isAdmin() {
    final session = SessionManager().session;
    return session.isAdmin();
  }

  Future<bool> isReady() async {
    var session = SessionManager().session;
    return await session.isReady();
  }

  Future<bool> sessionCheck() async {
    final session = SessionManager().session;
    return await session.sessionCheck();
  }
}
