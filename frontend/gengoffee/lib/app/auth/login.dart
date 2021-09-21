import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:gengoffee/app/home.dart';
import 'package:gengoffee/services/auth_service.dart';
import 'package:provider/provider.dart';

import 'register.dart';
import 'package:gengoffee/models/account.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

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

  http.StreamedResponse response = await request.send();
  String data = await response.stream.bytesToString();

  Map<String, dynamic> user = jsonDecode(data)['user'];
  String token = jsonDecode(data)['token'];

  print(user);

  if (response.statusCode == 200) {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
    } else {
      final prefs = new FlutterSecureStorage();
      await prefs.write(key: 'token', value: token);
    }

    return Account.fromJson(user);
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
  final authService = AuthService();
  bool busy = false;

  @override
  void initState() {
    super.initState();

    authService.isAuthenticated().then((authenticated) {
      if(authenticated) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home())
        );
      } else {
        busy = false;
      }
    });
  }

  String _pseudo;
  String _password;
  bool _loginError = false;

  void validateAndSave() {
    setState(() {
      _loginError = false;
    });
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      print('Form is valid \n');
      loginCall(_pseudo, _password).then((value) {
        if (value != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else {
          setState(() {
            _loginError = true;
          });
        }
      });
    } else {
      print('Form is invalid \n');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Provider<AuthService>(
      create: (_) => AuthService(),
      child: !busy ? Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (_loginError) Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 206, 198, 1),
                  borderRadius: BorderRadius.all(
                      Radius.circular(3)
                  )

              ),
              child: Text(
                "Wrong credentials",
                style: TextStyle(
                  color: Color.fromRGBO(132, 115, 113, 1),
                ),
              ),
            ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                SizedBox(width: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState.validate()) {
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Processing Data')));
                        validateAndSave();
                      }
                    },
                    child: Text('Login'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ) : Container(),
    );
  }
}
