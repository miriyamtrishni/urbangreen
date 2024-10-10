// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String? cityCouncil;
  final String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    this.cityCouncil,
    required this.role,
  });

  // Factory method to create a UserModel from a map
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      cityCouncil: data['cityCouncil'],
      role: data['role'] ?? 'user',
    );
  }

  // Method to convert UserModel to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'cityCouncil': cityCouncil,
      'role': role,
    };
  }
}
