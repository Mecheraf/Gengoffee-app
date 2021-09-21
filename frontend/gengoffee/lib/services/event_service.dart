import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gengoffee/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class EventService {
  AuthService authService = AuthService();
  Account _user;
  Map<String, dynamic> events;

  Future<Map> getEvents() async {
    Dio dio = new Dio();
    String token = await authService.getToken();
    dio.options.headers["Authorization"] = "Token $token";

    //Ici on récupère le token dans l'instance
    var response;
    if (kIsWeb) {
      response = await dio.get("http://127.0.0.1:8000/api/event/all");
    } else {
      response = await dio.get("http://10.0.2.2:8000/api/event/all");
    }
    //Grâce au token, on peut faire un appel api avec le token.
    print(response.data);
    events = jsonDecode(response.toString());
    return events;
    //Ici on définit la variable user
  }

  Future<void> isAttending() async {
    _user = await authService.getUser();
  }

  Future<void> subscribeEvent(_id) async {
    Dio dio = new Dio();
    print("This is id : $_id\n");
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? 0;
      dio.options.headers["Authorization"] = "Token $token";
    } else {
      final prefs = new FlutterSecureStorage();
      final String token = await prefs.read(key: 'token') ?? 0;
      dio.options.headers["Authorization"] = "Token $token";
    }
    //Ici on récupère le token dans l'instance
    var response;
    if (kIsWeb) {
      response = await dio.patch("http://127.0.0.1:8000/api/event/join/$_id");
    } else {
      response = await dio.patch("http://10.0.2.2:8000/api/event/join/$_id");
    }
    //Grâce au token, on peut faire un appel api avec le token.
    print(response.data);
  }

  Future<void> unsubscribeEvent(_id) async {
    Dio dio = new Dio();
    print("This is id : $_id\n");
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? 0;
      dio.options.headers["Authorization"] = "Token $token";
    } else {
      final prefs = new FlutterSecureStorage();
      final String token = await prefs.read(key: 'token') ?? 0;
      dio.options.headers["Authorization"] = "Token $token";
    }
    //Ici on récupère le token dans l'instance
    var response;
    if (kIsWeb) {
      response = await dio.patch("http://127.0.0.1:8000/api/event/quit/$_id");
    } else {
      response = await dio.patch("http://10.0.2.2:8000/api/event/quit/$_id");
    }
    //Grâce au token, on peut faire un appel api avec le token.
    print(response.data);
  }
}
