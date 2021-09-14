class Account {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final int age;
  final String city;
  final String country;
  final String nationality;
  final int gender;
  final String token;

  Account({this.username, this.email, this.firstName, this.lastName, this.age, this.city, this.country, this.nationality, this.gender, this.token});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      age: json['age'],
      city: json['city'],
      country: json['country'],
      nationality: json['nationality'],
      gender: json['gender'],
      token: json['token'],
    );
  }
}