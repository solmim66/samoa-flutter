import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

const String kManagerEmail = 'manager@saladanza.it';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'manager' | 'customer'

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });
}

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;
  bool get isManager => _currentUser?.email == kManagerEmail;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    if (user == null) {
      _currentUser = null;
    } else {
      _currentUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? user.email?.split('@')[0] ?? '',
        role: user.email == kManagerEmail ? 'manager' : 'customer',
      );
    }
    notifyListeners();
  }
}
