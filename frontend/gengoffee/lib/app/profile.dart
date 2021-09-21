import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gengoffee/models/account.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: MyProfileDisplay(),
    );
  }
}

class MyProfileDisplay extends StatefulWidget {
  @override
  MyProfileDisplayState createState() {
    return MyProfileDisplayState();
  }
}

enum Gender { Male, Female, Other }

class MyProfileDisplayState extends State<MyProfileDisplay> {
  Map<String, dynamic> user;

  Future<void> getinfo() async {
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
      response = await dio.get("http://127.0.0.1:8000/api/auth/");
    } else {
      response = await dio.get("http://10.0.2.2:8000/api/auth/");
    }
    //Grâce au token, on peut faire un appel api avec le token.
    print(response.data);
    setState(() => user = jsonDecode(response.toString()));
    //Ici on définit la variable user
  }

  Future<Account> updateProfile(email, pseudo, firstName, lastName, age, city,
      country, genderIndex) async {
    MultipartRequest request;
    if (kIsWeb) {
      request = http.MultipartRequest(
          'PUT', Uri.parse('http://127.0.0.1:8000/api/auth/update'));
    } else {
      request = http.MultipartRequest(
          'PUT', Uri.parse('http://10.0.2.2:8000/api/auth/update'));
    }
    request.fields.addAll({
      'username': pseudo,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'age': age.toString(),
      'city': city,
      'country': country,
      'gender': genderIndex.toString()
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

  final _formKey = GlobalKey<FormState>();

  void validateAndSave() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      print('Form is valid');
    } else {
      print('Form is invalid');
    }
  }

  String _pseudo;
  String _firstName;
  String _lastName;
  String _age;
  String _city;
  String _email;
  String _country;
  Gender _gender;

  void init() {
    if (user == null) {
      //Si le user n'est pas set, on getinfo
      getinfo();
    }
    if (user != null) {
      print("Hello");
      //Il faut impérativement vérifier que user n'est pas null
      _pseudo = user["username"];
      _firstName = user["first_name"]["value"];
      _lastName = user["last_name"]["value"];
      _city = user["city"]["value"];
      _email = user["email"];
      _country = user["country"]["value"];
      _age = user["age"]["value"].toString();
      if (user["gender"]["value"] == 0) {
        _gender = Gender.Male;
      } else if (user["gender"]["value"] == 1) {
        _gender = Gender.Female;
      } else {
        _gender = Gender.Other;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pseudo == null) {
      init();
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Hello, $_pseudo! How are you?', //Ici on print le username
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          // input field for pseudo
          TextFormField(
            controller: TextEditingController(text: _email),
            decoration: InputDecoration(
                labelText: 'Email : ', icon: Icon(Icons.alternate_email)),
            validator: (value) {
              if (value.isEmpty) {
                value = user["email"];
              }

              bool emailIsValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(_email);
              if (!emailIsValid) {
                return 'Email must be a valid email address';
              }
              return null;
            },
            onChanged: (value) {
              _email = value;
            },
          ),
          // input field for mail
          TextFormField(
            controller: TextEditingController(
              text: _firstName,
            ),
            decoration: InputDecoration(
              labelText: 'First Name : ',
              icon: Icon(Icons.location_history),
            ),
            validator: (value) {
              if (value.isEmpty) {
                value = _firstName;
              }
              return null;
            },
            onChanged: (value) {
              _firstName = value;
            },
          ),
          TextFormField(
            controller: TextEditingController(
              text: _lastName,
            ),
            decoration: InputDecoration(
              labelText: 'Last Name : ',
              icon: Icon(Icons.location_history),
            ),
            validator: (value) {
              if (value.isEmpty) {
                value = _lastName;
              }
              return null;
            },
            onChanged: (value) {
              _lastName = value;
            },
          ),
          TextFormField(
            controller: TextEditingController(
              text: _country,
            ),
            decoration: InputDecoration(
              labelText: 'Country : ',
              icon: Icon(Icons.location_history),
            ),
            validator: (value) {
              if (value.isEmpty) {
                value = _country;
              }
              return null;
            },
            onChanged: (value) {
              _country = value;
            },
          ),
          TextFormField(
            controller: TextEditingController(
              text: _city,
            ),
            decoration: InputDecoration(
              labelText: 'City : ',
              icon: Icon(Icons.location_history),
            ),
            validator: (value) {
              if (value.isEmpty) {
                value = _city;
              }
              return null;
            },
            onChanged: (value) {
              _city = value;
            },
          ),

          TextFormField(
            controller: TextEditingController(
              text: _age,
            ),
            decoration: InputDecoration(
              labelText: 'Age : ',
              icon: Icon(Icons.location_history),
            ),
            validator: (value) {
              if (int.parse(value) < 13) {
                return 'Age must be greater than 13';
              }
              if (value.isEmpty) {
                value = _age;
              }
              return null;
            },
            onChanged: (value) {
              _age = value;
            },
          ),
          // input field for country
          DropdownButton<Gender>(
              value: _gender,
              onChanged: (Gender newValue) {
                setState(() {
                  _gender = newValue;
                });
              },
              items: Gender.values.map((Gender classType) {
                return DropdownMenuItem<Gender>(
                    value: classType, child: Text(classType.toString()));
              }).toList()),

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
                  updateProfile(_email, _pseudo, _firstName, _lastName, _age,
                          _city, _country, _gender.index)
                      .then((value) => {print(value)});
                }
              },
              child: Text('Mettre à jour le profile'),
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
