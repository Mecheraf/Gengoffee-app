import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gengoffee/models/account.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class Create_event extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create_Event')),
      body: MyEventForm(),
    );
  }
}

class MyEventForm extends StatefulWidget {
  @override
  MyEventFormState createState() {
    return MyEventFormState();
  }
}

Future<Account> create_eventCall(
    name, category, date, location, price, description, tags) async {
  MultipartRequest request;
  if (kIsWeb) {
    request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/api/event/create'));
  } else {
    request = http.MultipartRequest(
        'POST', Uri.parse('http://10.0.2.2:8000/api/event/create'));
  }

  request.fields.addAll({
    'name': name,
    'category': category.toString(),
    'date': date,
    'location': location,
    'price': price.toString(),
    'description': description,
    'tags': tags
  });

  if (kIsWeb) {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? 0;
    request.headers.addAll({'Authorization': "Token $token"});
  } else {
    final prefs = new FlutterSecureStorage();
    final String token = await prefs.read(key: 'token') ?? 0;
    request.headers.addAll({'Authorization': "Token $token"});
  }

  http.StreamedResponse response = await request.send();
  String data = await response.stream.bytesToString();
  if (response.statusCode == 201) {
    print(data);
    return Account.fromJson(jsonDecode(data));
  } else {
    print(response.reasonPhrase);
    print(data);
  }
  return null;
}

class MyEventFormState extends State<MyEventForm> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _date;
  String _location;
  int _price;
  String _description;
  String _tags;

  void validateAndSave() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      print('Form is valid');
    } else {
      print('Form is invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
                labelText: "Nom de l'événement : ", icon: Icon(Icons.title)),
            validator: (value) {
              if (value.isEmpty) {
                return "L'événement doit avoir un nom";
              }
              return null;
            },
            onChanged: (value) {
              _name = value;
            },
          ), // input field for pseudo
          TextFormField(
            decoration: InputDecoration(
                labelText: "Lieu où se tient l'événement : ",
                icon: Icon(Icons.add_location)),
            validator: (value) {
              if (value.isEmpty) {
                return "L'événement doit avoir un lieu";
              }
              return null;
            },
            onChanged: (value) {
              _location = value;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: 'description : ', icon: Icon(Icons.text_fields)),
            validator: (value) {
              if (value.length < 20) {
                return 'La description doit faire au moins 20 caractères.';
              }
              return null;
            },
            onChanged: (value) {
              _description = value;
            },
          ), // input field for mail
          TextFormField(
            decoration:
                InputDecoration(labelText: 'Prix : ', icon: Icon(Icons.euro)),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
            validator: (value) {
              if (int.parse(value) < 0) {
                return 'Le prix ne peut être inférieur à 0.';
              }
              return null;
            },
            onChanged: (value) {
              _price = int.parse(value);
            },
          ), // input field for price
          DateTimeFormField(
            decoration: const InputDecoration(
              hintStyle: TextStyle(color: Colors.black45),
              errorStyle: TextStyle(color: Colors.redAccent),
              //border: OutlineInputBorder(),
              icon: Icon(Icons.event_note),
              labelText: 'My Super Date Time Field',
            ),
            autovalidateMode: AutovalidateMode.always,
            validator: (e) =>
                (e?.day ?? 0) < 1 ? 'Please not the first day' : null,
            onDateSelected: (DateTime value) {
              _date = value.toString();
            },
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: "Ajoutez des Tags : ",
                icon: Icon(Icons.add_location)),
            validator: (value) {
              if (value.isEmpty) {
                return "Tags obligatoire";
              }
              return null;
            },
            onChanged: (value) {
              _tags = value;
            },
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                  validateAndSave();
                  print(_name +
                      _date +
                      _location +
                      _price.toString() +
                      _description +
                      _tags);
                  create_eventCall(_name, 1, _date, _location, _price,
                          _description, _tags)
                      .then((value) => {print(value)});
                }
              },
              child: Text('Create your event'),
            ),
          ),
          Center(
              child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Go back Home'),
          )),
          // Add TextFormFields and ElevatedButton here.
        ],
      ),
    );
  }
}
