import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';

class NotificationRequests {
  // final String baseUrl = 'http://10.0.2.2:3000'; // ENDPOINT per il localhost
  final String baseUrl = 'http://51.20.181.177:3000'; // ENDPOINT per AWS

  // Crea una nuova notifica
  Future<NotificationModel> createNotification(String token, Map<String, dynamic> notificationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/notifications/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(notificationData),
    );

    if (response.statusCode == 201) {
      return NotificationModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create notification');
    }
  }

  // Recupera tutte le notifiche dell'utente
  Future<List<NotificationModel>> getNotificationsByUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((notification) => NotificationModel.fromJson(notification)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  // Segna una notifica come letta
  Future<void> markAsRead(String token, int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/notifications/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  // Elimina una notifica
  Future<void> deleteNotification(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/notifications/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }

  // Elimina tutte le notifiche contemporaneamente
  Future<void> deleteAllNotification(String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/notifications/delete-all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}
