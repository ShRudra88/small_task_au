import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? image;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.image,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, username, email, firstName, lastName, image];
}
