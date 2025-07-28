import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Sign in with email and password
  Future<UserModel?> signIn(String email, String password) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.trim())
        .where('password', isEqualTo: password.trim())
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    _currentUser = UserModel.fromMap(doc.id, doc.data());
    return _currentUser;
  }

  /// Get currently logged in user model (from memory only)
  UserModel? getCurrentUserModel() {
    return _currentUser;
  }

  /// Logout (just clear memory)
  Future<void> signOut() async {
    _currentUser = null;
  }

  /// Create user in Firestore
  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await _firestore.collection('users').add({
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
  }
}
