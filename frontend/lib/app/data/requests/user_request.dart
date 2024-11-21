import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserRequests {
  final String baseUrl = 'http://127.0.0.1:3000';

  // Funzione per ottenere i dati dell'utente
  Future<User> getUserData(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return User.fromJson(jsonResponse);
    } else {
      throw Exception('Error loading user data');
    }
  }

  // Funzione di login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('Risposta del backend: ${response.body}');  // Aggiungi questo per il debug

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return {
        'user': User.fromJson(jsonResponse['user']),
        'accessToken': jsonResponse['accessToken'],
        'refreshToken': jsonResponse['refreshToken']
      };
    } else {
      throw Exception('Login failed');
    }
  }

  // Funzione di registrazione
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    print('Risposta del backend: ${response.body}');  // Aggiungi questo per il debug

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      return {
        'user': jsonResponse['user'],
        'accessToken': jsonResponse['token'],
      }; // Restituisce i dati necessari
    } else if (response.statusCode == 400 || response.statusCode == 409) {
      final jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['error'] ?? 'Registration failed'); // Cattura l'errore specifico
    } else {
      throw Exception('Registration failed');
    }
  }

  // Funzione per aggiornare i dati dell'utente
  Future<void> updateUser(String token, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  // Funzione per eliminare l'utente
  Future<void> deleteUser(String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/users'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  // Funzione per resettare la password
  Future<void> resetPassword(String email, String newPassword) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'newPassword': newPassword,
      }),
    );

    print('Risposta del backend: ${response.body}');  // Aggiungi questo per il debug

    if (response.statusCode != 200) {
      throw Exception('Failed to reset password: ${response.body}');
    }
  }

  // Funzione per rinnovare il token di accesso
  Future<void> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null) {
      print('Refresh token mancante');
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newAccessToken = data['accessToken'];

      // Salva il nuovo access token
      await prefs.setString('accessToken', newAccessToken);
      print('Nuovo access token ottenuto: $newAccessToken');
    } else {
      print('Impossibile ottenere un nuovo access token');
    }
  }
}
