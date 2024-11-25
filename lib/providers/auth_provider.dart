import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  final AuthService _authService = AuthService();

  UserModel? get user => _user;

  Future<void> login(String username, String password) async {
    try {
      _user = await _authService.login(username, password);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  String? get token => _user?.token;
  String? get email => _user?.email;
}
