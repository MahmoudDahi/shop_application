import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  List<String> _category = [];

  List<Product> get items {
    return [..._items];
  }

  List<String> get category {
    return [..._category];
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse('https://fakestoreapi.com/products');

    try {
      final response = await http.get(url);
      print(json.decode(response.body));
      if (response.body == 'null') {
        return;
      }

      final data = json.decode(response.body) as List<dynamic>;

      final List<Product> loadedProducts = [];
      data.forEach(
        (prodData) {
          loadedProducts.add(
            Product(
              id: prodData['id'].toString(),
              title: prodData['title'] as String,
              description: prodData['description'] as String,
              price: prodData['price'].toDouble(),
              imageUrl: prodData['image'] as String,
              category: prodData['category'] as String,
            ),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> fetchAllCategory() async {
    final url = Uri.parse('https://fakestoreapi.com/products/categories');
    try {
      final response = await http.get(url);
      if (response.statusCode != 200)
        throw HttpException(response.body.toString());

      final responseData = json.decode(response.body) as List<dynamic>;
      List<String> newCateg = [];

      for (var cat in responseData) {
        newCateg.add(cat);
      }
      _category = newCateg;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> filterProduct(
      String filterCategory, String sort, int limit) async {
    String categoryFilterPath = '';
    if (filterCategory.isNotEmpty)
      categoryFilterPath = '/category/$filterCategory';

    final url = Uri.parse(
        'https://fakestoreapi.com/products$categoryFilterPath?sort=$sort&limit=$limit');

    try {
      final response = await http.get(url);
      print(json.decode(response.body));
      if (response.body == 'null') {
        return;
      }

      final data = json.decode(response.body) as List<dynamic>;

      final List<Product> loadedProducts = [];
      data.forEach(
        (prodData) {
          loadedProducts.add(
            Product(
              id: prodData['id'].toString(),
              title: prodData['title'] as String,
              description: prodData['description'] as String,
              price: prodData['price'].toDouble(),
              imageUrl: prodData['image'] as String,
              category: prodData['category'] as String,
            ),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> searchProduct(String productID) async {
    final url = Uri.parse('https://fakestoreapi.com/products/$productID');

    try {
      final response = await http.get(
        url,
      );

      if (response.statusCode != 200)
        throw HttpException(response.body.toString());

      final responseData = json.decode(response.body) as dynamic;
      final prodData = Product(
        id: responseData['id'].toString(),
        title: responseData['title'] as String,
        description: responseData['description'] as String,
        price: responseData['price'].toDouble(),
        imageUrl: responseData['image'] as String,
        category: responseData['category'] as String,
      );

      _items = [];
      _items.add(prodData);
      notifyListeners();
    } catch (error) {
      print('shopapp $error');
      rethrow;
    }
  }

  Future<Product> fetchProductById(String productID) async {
    final url = Uri.parse('https://fakestoreapi.com/products/$productID');

    try {
      final response = await http.get(
        url,
      );

      if (response.statusCode != 200)
        throw HttpException(response.body.toString());

      final responseData = json.decode(response.body) as dynamic;
      final prodData = Product(
        id: responseData['id'].toString(),
        title: responseData['title'] as String,
        description: responseData['description'] as String,
        price: responseData['price'].toDouble(),
        imageUrl: responseData['image'] as String,
        category: responseData['category'] as String,
      );

      return prodData;

      //cuz it is not real so i dont save or reload all product for new product
    } catch (error) {
      print('shopapp $error');
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse('https://fakestoreapi.com/products');

    try {
      await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'image': product.imageUrl,
            'category': product.category,
          },
        ),
      );
      //cuz it is not real so i dont save or reload all product for new product
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final url = Uri.parse('https://fakestoreapi.com/products/$id');
    try {
      final response = await http.put(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'image': product.imageUrl,
          'category': product.category,
        }),
      );
      if (response.statusCode != 200) {
        throw HttpException('Could not delete product.');
      }
    } catch (error) {
      throw error;
    }
    ;
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse('https://fakestoreapi.com/products/$id');

    try {
      final response = await http.delete(url);
      if (response.statusCode != 200) {
        throw HttpException('Could not delete product.');
      }
    } catch (error) {
      throw error;
    }
  }
}
