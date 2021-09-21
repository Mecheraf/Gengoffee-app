import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gengoffee/models/account.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: MyCustomForm(),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

enum Gender { Male, Female, Other }
List<String> nationalities = ["FRE", "JAP", "OTHER"];

Future<Account> registerCall(email, password, password2, pseudo, firstName,
    lastName, age, city, country, nationality, genderIndex) async {
  MultipartRequest request = http.MultipartRequest(
      'POST', Uri.parse('http://127.0.0.1:8000/api/auth/register'));

  request.fields.addAll({
    'username': pseudo,
    'email': email,
    'password': password,
    'password2': password2,
    'first_name': firstName,
    'last_name': lastName,
    'age': age.toString(),
    'city': city,
    'country': country,
    'nationality': nationality,
    'gender': genderIndex.toString()
  });

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

class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  String _password2;
  String _pseudo;
  String _firstName;
  String _lastName;
  int _age;
  String _city;
  String _country;
  String _nationality;
  Gender _gender = Gender.Male;

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
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          ), // input field for pseudo
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Email : ', icon: Icon(Icons.alternate_email)),
            validator: (value) {
              if (value.isEmpty) {
                return 'Email cannot be blank';
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
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Confirm password : ', icon: Icon(Icons.lock)),
            obscureText: true,
            validator: (value) {
              if (value.isEmpty) {
                return 'Password cannot be blank';
              }

              if (value != _password) {
                return 'Passwords must match';
              }

              return null;
            },
            onChanged: (value) {
              _password2 = value;
            },
          ), // input field for password2
          TextFormField(
            decoration: InputDecoration(
              labelText: 'First Name : ',
              icon: Icon(Icons.location_history),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'First Name cannot be blank';
              }
              return null;
            },
            onChanged: (value) {
              _firstName = value;
            },
          ), // input field for first_name
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Last Name : ',
              icon: Icon(Icons.location_history),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Last Name cannot be blank';
              }
              return null;
            },
            onChanged: (value) {
              _lastName = value;
            },
          ), // input field for last name
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Age : ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
            validator: (value) {
              if (int.parse(value) < 13) {
                return 'Age must be greater than 13';
              }
              return null;
            },
            onChanged: (value) {
              _age = int.parse(value);
            },
          ), // input field for age
          TextFormField(
            decoration: InputDecoration(
              labelText: 'City : ',
              icon: Icon(Icons.location_city),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'City cannot be blank';
              }
              return null;
            },
            onChanged: (value) {
              _city = value;
            },
          ), // input field for city
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Country : ',
              icon: Icon(Icons.alternate_email),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Country cannot be blank';
              }
              return null;
            },
            onChanged: (value) {
              _country = value;
            },
          ), // input field for country
          DropdownButton<String>(
              value: _nationality,
              onChanged: (String newValue) {
                setState(() {
                  _nationality = newValue;
                });
              },
              items: nationalities
                  .map<DropdownMenuItem<String>>((String nationality) {
                return DropdownMenuItem<String>(
                    value: nationality, child: Text(nationality));
              }).toList()), // input field for nationality
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
                  registerCall(
                      _email,
                      _password,
                      _password2,
                      _pseudo,
                      _firstName,
                      _lastName,
                      _age,
                      _city,
                      _country,
                      _nationality,
                      _gender.index)
                      .then((value) => {print(value)});
                }
              },
              child: Text('Register'),
            ),
          ),
          Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go back to Login'),
              )),
          // Add TextFormFields and ElevatedButton here.
        ],
      ),
    );
  }
}
