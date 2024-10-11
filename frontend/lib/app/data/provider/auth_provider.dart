import 'dart:convert';

import 'package:flutter/material.dart';
import '../requests/auth_request.dart';

class AuthProvider with ChangeNotifier {
  String _token = '';
  bool get isAuthenticated => _token.isNotEmpty;

  Future<void> login(String email, String password) async {
    final response = await AuthRequests.login(email, password);
    if (response.statusCode == 200) {
      _token = jsonDecode(response.body)['token'];
      notifyListeners();
    } else {
      throw Exception('Login failed');
    }
  }
}
