import 'dart:ffi';

import 'package:flutter/Material.dart';
import 'package:flutter_complete_guide/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //convert date into JSON

import './product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String authToken;
  final String userId;

  ProductsProvider(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [
      ..._items
    ]; //return just the _items mean return the pointer of _items, but ... mean return a copy of the _items not the pointer.
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => id == element.id);
  }

  Future<void> fetchProductsFromServer([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://flutter-project-c3fdd-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          "https://flutter-project-c3fdd-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=" +
              authToken;
      final favoriterResponse = await http.get(url);
      final favoriteData = jsonDecode(favoriterResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData["title"],
          description: productData["description"],
          price: productData["price"],
          imageUrl: productData["imageUrl"],
          isFavorite: favoriteData == null
              ? false
              : favoriteData[productId] ??
                  false, //?? means if there is no entry for prodId it will be false
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        "https://flutter-project-c3fdd-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=" +
            authToken;
    try {
      final response = await http.post(url,
          body: json.encode({
            "title": product.title,
            "description": product.description,
            "imageUrl": product.imageUrl,
            "price": product.price,
            "creatorId": userId
          }));

      final newProduct = Product(
          id: json.decode(response.body)["name"],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners(); // to notify all the widget that listening this class that a data has changed

    } catch (error) {
      throw error;
    }
    // .then((response) {

    // }).catchError((error) {
    //
    //  });
  }

  Future<void> updateProduct(String id, Product updatedProduct) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      final url =
          "https://flutter-project-c3fdd-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=" +
              authToken;
      await http.patch(url, //TODO add try catch
          body: jsonEncode({
            "title": updatedProduct.title,
            "description": updatedProduct.description,
            "imageUrl": updatedProduct.imageUrl,
            "price": updatedProduct.price,
          }));
      _items[productIndex] = updatedProduct;
      notifyListeners();
    } else {
      print("cannot update a product that does not exist!");
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://flutter-project-c3fdd-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=" +
            authToken;
    // we store the deleted product in the memory in case of error occurs
    final deletedProductIndex =
        _items.indexWhere((element) => element.id == id);
    var deletedProduct = _items[deletedProductIndex];
    _items.removeAt(deletedProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(deletedProductIndex, deletedProduct);
      notifyListeners();
      throw HttpException("Could not delete product.");
    }
    deletedProduct = null;
  }
}
