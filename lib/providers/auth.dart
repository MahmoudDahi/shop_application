import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class User {
  final int id;
  final String email;
  final String username;
  final String phonenumber;
  final String address;

  User(
    this.id,
    this.email,
    this.username,
    this.phonenumber,
    this.address,
  );
}

class Auth extends ChangeNotifier {
  String? _token;

  bool get isAuth {
    return token != '';
  }

  String get token {
    if (_token != null) {
      return _token!;
    }
    return '';
  }

  Future<User> getProfileUser() async {
    final url = Uri.parse('https://fakestoreapi.com/users/1');
    try {
      final response = await http.get(
        url,
      );
      if (response.statusCode != 200) {
        throw HttpException(response.body.toString());
      }
      final responseData = json.decode(response.body) as dynamic;
      return User(
        responseData['id'] as int,
        responseData['email'],
        '${responseData['name']['firstname']} ${responseData['name']['lastname']}',
        responseData['phone'],
        '${responseData['address']['street']} , ${responseData['address']['city']}',
      );
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> signin(String? username, String? password) async {
    final url = Uri.parse('https://fakestoreapi.com/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {
          "content-type": "application/json",
        },
        body: json.encode(
          {
            "username": username,
            "password": password,
          },
        ),
      );
      if (response.statusCode != 200) {
        throw HttpException(response.body.toString());
      }
      final responseData = json.decode(response.body);

      _token = responseData['token'].toString();

      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(
    String? email,
    String? password,
    String? username,
  ) async {
    final url = Uri.parse('https://fakestoreapi.com/users');
    try {
      final response = await http.post(
        url,
        headers: {
          "content-type": "application/json",
        },
        body: json.encode(
          {
            "email": email,
            "username": username,
            "password": password,
          },
        ),
      );
      if (response.statusCode != 200) {
        throw HttpException(response.body.toString());
      }
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('userData')) {
        return false;
      }

      final extractedUserData = prefs.getString('userData');
      final userData = json.decode(extractedUserData!) as Map<String, dynamic>;

      _token = userData['token'].toString();

      notifyListeners();
    } catch (error) {
      rethrow;
    }
    return true;
  }

  Future<void> logout() async {
    _token = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
