import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../requests/user_request.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _accessToken; // Per memorizzare l'access token

  User? get user => _user;
  bool get isLoading => _isLoading;

  // Funzione di login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await UserRequests().login(email, password);
      _user = result['user'];

      // Salva i token e memorizza l'access token nel provider
      _accessToken = result['accessToken'];
      final refreshToken = result['refreshToken'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', _accessToken!);
      await prefs.setString('refreshToken', refreshToken);

      notifyListeners(); // Notifica il cambiamento

    } catch (e) {
      print('Error during login: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Funzione per caricare i dati dell'utente
  Future<void> fetchUserData(String token) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    if (token == null) {
      print('Token non trovato, reindirizzo al login');
      return; // Puoi aggiungere la logica per il redirect al login qui
    }

    try {
      _user = await UserRequests().getUserData(token);
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Funzione per la registrazione dell'utente
  Future<void> register(Map<String, dynamic> userData) async {
    try {
      await UserRequests().register(userData);
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    }
    notifyListeners();
  }

  // Funzione per la modifica dei dati dell'utente
  Future<void> updateUser(String token, Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await UserRequests().updateUser(token, userData);
      _user = await UserRequests().getUserData(token);  // Ricarica i dati utente aggiornati
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Funzione per resettare la password
  Future<void> resetPassword(String email, String newPassword) async {
    try {
      await UserRequests().resetPassword(email, newPassword);
    } catch (e) {
      print('Error resetting password: $e');
      throw e;
    }
  }

  // Funzione per la cancellazione dell'utente
  Future<void> deleteUser(String token) async {
    try {
      await UserRequests().deleteUser(token);
      _user = null; // Imposta user a null dopo la cancellazione
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
    notifyListeners();
  }

  // Funzione per ottenere i dati dell'utente
  Future<void> getUserData(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await UserRequests().getUserData(token);
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
