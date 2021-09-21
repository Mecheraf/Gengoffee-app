import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gengoffee/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  String token;
  Account user;

  Future<void> getToken() async {
    if (kIsWeb) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString("token");
    } else {
      final prefs = new FlutterSecureStorage();
      token = await prefs.read(key: 'token');
    }
  }

  Future<void> getUser() async {
    await getToken();
    if(token == null || token == "") return false;

    Dio dio = new Dio();
    dio.options.headers["Authorization"] = "Token $token";

    var response;

    try {
      if (kIsWeb) {
        response = await dio.get("http://127.0.0.1:8000/api/auth/");
      } else {
        response = await dio.get("http://10.0.2.2:8000/api/auth/");
      }

      user = Account.fromJson(response.data);
    } on DioError catch (e) {
      print(e.message);
    }
  }

  Future<bool> isAuthenticated() async {
    await getUser();

    if(user != null) {
      return true;
    } else {
      return false;
    }
  }


}