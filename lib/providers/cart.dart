import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shop_app/models/http_exception.dart';
import 'package:flutter_shop_app/providers/products.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

enum ActionQuantity { Inc, Dec }

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  List<CartItem> _carts = [];

  List<CartItem> get items {
    return [..._carts];
  }

  int get itemCount {
    return _carts.length;
  }

  double get totalAmount {
    var total = 0.0;
    _carts.forEach(
      (cartItem) {
        total += cartItem.price * cartItem.quantity;
      },
    );
    return total;
  }

  Future<void> fetchAndSetCartForUser() async {
    _carts = [];
    //user id in this case static because not have database
    final url = Uri.parse('https://fakestoreapi.com/carts/user/2');
    try {
      final response = await http.get(url);
      if (response.statusCode != 200)
        throw HttpException(response.body.toString());

      final responseData = json.decode(response.body) as List<dynamic>;

      for (var cartItem in responseData) {
        final products = cartItem['products'] as List<dynamic>;
        for (var product in products) {
          await Products()
              .fetchProductById(product['productId'].toString())
              .then((prodData) {
            print(prodData.category);
            _carts.add(
              CartItem(
                id: prodData.id,
                title: prodData.title,
                quantity: product['quantity'] as int,
                price: prodData.price,
              ),
            );
          });
        }
        ;
      }
      ;

      notifyListeners();
    } catch (error) {
      print('shopapp $error');
      throw error;
    }
  }

  Future<void> addItem(
    String productId,
    int quantity,
    String dateTime,
  ) async {
    final url = Uri.parse('https://fakestoreapi.com/carts');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'userId': "5",
          'date': dateTime,
          'products': {
            'productId': productId,
            'quantity': quantity.toString(),
          },
        }),
      );

      if (response.statusCode != 200)
        throw HttpException(response.body.toString());

      fetchAndSetCartForUser();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  CartItem findById(String id) {
    return _carts.firstWhere((cart) => cart.id == id);
  }

  Future<void> updateCartItem(
    String productId,
    int quantity,
    ActionQuantity actionQuantity,
  ) async {
    if (actionQuantity == ActionQuantity.Dec) {
      quantity--;
    } else {
      quantity++;
    }
    //check quantity if below 1 that's meaning remove it
    if (quantity == 0) {
      removeSingleItem(productId);
      return;
    }

    final url = Uri.parse('https://fakestoreapi.com/carts/7');
    try {
      final response = await http.put(
        url,
        body: json.encode({
          'userId': 3,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'products': {
            'productId': productId,
            'quantity': quantity,
          },
        }),
      );

      if (response.statusCode != 200)
        throw HttpException(response.body.toString());

      final oldCart = findById(productId);

      _carts[_carts.indexWhere((element) => element.id == productId)] =
          CartItem(
              id: oldCart.id,
              title: oldCart.title,
              quantity: quantity,
              price: oldCart.price);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> removeSingleItem(String productId) async {
    if (!_carts
        .contains(_carts.firstWhere((element) => element.id == productId))) {
      return;
    }
    try {
      final url = Uri.parse('https://fakestoreapi.com/carts/6');
      final response = await http.delete(url, headers: {
        "content-type": "application/json",
      });
      if (response.statusCode != 200)
        throw HttpException(response.body.toString());

      _carts.remove(_carts.firstWhere((element) => element.id == productId));

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
