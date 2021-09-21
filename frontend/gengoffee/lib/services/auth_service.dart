import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gengoffee/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  String _token;
  Account _user;

  Future<String> getToken() async {
    if (kIsWeb) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString("token");
    } else {
      final prefs = new FlutterSecureStorage();
      _token = await prefs.read(key: 'token');
    }
    return _token;
  }

  Future<Account> getUser() async {
    await getToken();
    if (_token == null || _token == "") return null;

    Dio dio = new Dio();
    dio.options.headers["Authorization"] = "Token $_token";

    var response;

    try {
      if (kIsWeb) {
        response = await dio.get("http://127.0.0.1:8000/api/auth/");
      } else {
        response = await dio.get("http://10.0.2.2:8000/api/auth/");
      }

      _user = Account.fromJson(response.data);
    } on DioError catch (e) {
      print(e.message);
    }
    return _user;
  }

  Future<bool> isAuthenticated() async {
    await getUser();

    if (_user != null) {
      return true;
    } else {
      return false;
    }
  }
}
