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

  factory Account.fromJson(dynamic json) {
    return Account(
      username: json['username'],
      email: json['email'],
      firstName: json['first_name']['value'],
      lastName: json['last_name']['value'],
      age: json['age']['value'],
      city: json['city']['value'],
      country: json['country']['value'],
      gender: json['gender']['value'],
      nationality: json['nationality']
    );
  }
}