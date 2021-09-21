import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gengoffee/services/event_service.dart';
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
  EventService eventService = EventService();
  //Pour appeler les fonctions de event_services.dart

  Map<String, dynamic> events;
  Future<void> updateEvents() async {
    events = await eventService.getEvents();
    setState(() {});
    //Ici on définit la variable user
  }

  @override
  Widget build(BuildContext context) {
    if (events == null) {
      //Si les events ne sont pas set, on getinfo
      updateEvents().then((value) => null);
    }
    List<dynamic> items = events.values.toList();
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
                      eventService
                          .subscribeEvent(index + 1)
                          .then((value) => {});
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
                      eventService
                          .unsubscribeEvent(index + 1)
                          .then((value) => {});
                    },
                  ),
                )
              ],
            ),
          );
        });
  }
}
