import 'dart:convert';
import 'register.dart';
import 'profile.dart';
import 'create_event.dart';
import 'package:gengoffee/account.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'display_all_event.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: MyLoginForm(),
    );
  }
}

class MyLoginForm extends StatefulWidget {
  @override
  MyLoginFormState createState() {
    return MyLoginFormState();
  }
}

Future<Account> loginCall(pseudo, password) async {
  MultipartRequest request;

  if (kIsWeb) {
    request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/api/auth/login'));
  } else {
    request = http.MultipartRequest(
        'POST', Uri.parse('http://10.0.2.2:8000/api/auth/login'));
  }

  request.fields.addAll({
    'username': pseudo,
    'password': password,
  });

  request.headers.addAll({
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': "*/*",
    'connection': 'keep-alive',
    'Accept-Encoding': 'gzip, deflate, br',
  });

  http.StreamedResponse response = await request.send();
  String data = await response.stream.bytesToString();

  print(data);
  Map<String, dynamic> user = jsonDecode(data);

  if (response.statusCode == 200) {
    if (!kIsWeb) {
      final prefs = new FlutterSecureStorage();
      await prefs.write(key: 'token', value: user["token"]);
    } else {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', user["token"]);
    }
    return Account.fromJson(jsonDecode(data));
  } else {
    print(response.reasonPhrase);
    print(data);
  }
  return null;
}

class MyLoginFormState extends State<MyLoginForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  String _pseudo;
  String _password;

  void validateAndSave() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      print('Form is valid \n');
    } else {
      print('Form is invalid \n');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Pseudo : ', icon: Icon(Icons.location_history)),
            validator: (value) {
              if (value.isEmpty) {
                return 'Pseudo cannot be blank';
              }
              return null;
            },
            onChanged: (value) {
              _pseudo = value;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Password : ', icon: Icon(Icons.lock)),
            obscureText: true,
            validator: (value) {
              if (value.isEmpty) {
                return 'Password cannot be blank';
              }
              return null;
            },
            onChanged: (value) {
              _password = value;
            },
          ), // input field for password
          ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Register()));
              },
              child: Text('Not registered yet ?'),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: Colors.grey))))),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Profile()));
            },
            child: Text('Check your profile'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Create_event()));
            },
            child: Text('Créer un événement'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DisplayAllEvents()));
            },
            child: Text('Montrer tous les événements.'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState.validate()) {
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                  validateAndSave();
                  loginCall(_pseudo, _password).then((value) => {
                        //print("I am token : " + value.token + "\n")
                      });
                }
              },
              child: Text('Login'),
            ),
          ),
        ],
      ),
    );
  }
}
