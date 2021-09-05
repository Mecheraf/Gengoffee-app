import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class DisplayAllEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DisplayAllEvents')),
      body: MyDisplayAllEventsDisplay(),
    );
  }
}

class MyDisplayAllEventsDisplay extends StatefulWidget {
  @override
  MyDisplayAllEventsDisplayState createState() {
    return MyDisplayAllEventsDisplayState();
  }
}

class MyDisplayAllEventsDisplayState extends State<MyDisplayAllEventsDisplay> {
  Map<String, dynamic> events;

  Future<void> getEvents() async {
    Dio dio = new Dio();
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
      response = await dio.get("http://127.0.0.1:8000/api/event/all");
    } else {
      response = await dio.get("http://10.0.2.2:8000/api/event/all");
    }
    //Grâce au token, on peut faire un appel api avec le token.
    print(response.data);
    setState(() => events = jsonDecode(response.toString()));
    //Ici on définit la variable user
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

  @override
  Widget build(BuildContext context) {
    if (events == null) {
      //Si les events ne sont pas set, on getinfo
      getEvents();
    }

    final List<dynamic> items = events.values.toList();
    print("I am test ${items[1].length}");
    return ListView.builder(
        itemCount: items[1].length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('${items[1][index]}'),
            subtitle: Column(
              children: <Widget>[
                Container(
                  child: ElevatedButton(
                    child: Text("Inscription à l'évènement"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Processing Data')));
                      subscribeEvent(index + 1).then((value) => {});
                    },
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    child: Text("Se désinscrire de l'évènement"),
                    style: ElevatedButton.styleFrom(primary: Colors.red[800]),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Processing Data')));
                      unsubscribeEvent(index + 1).then((value) => {});
                    },
                  ),
                )
              ],
            ),
          );
        });
  }
}
