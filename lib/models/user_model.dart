// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String password;
  final String name;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? '',
    );
  }
}
