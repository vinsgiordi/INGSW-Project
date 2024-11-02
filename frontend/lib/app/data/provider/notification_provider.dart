import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../requests/notification_request.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;


  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  // Recupera tutte le notifiche per l'utente
  Future<void> fetchNotificationsByUser(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await NotificationRequests().getNotificationsByUser(token);
    } catch (e) {
      print('Error fetching notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Crea una nuova notifica
  Future<void> createNotification(String token, Map<String, dynamic> notificationData) async {
    try {
      await NotificationRequests().createNotification(token, notificationData);
      fetchNotificationsByUser(token); // Ricarica le notifiche
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // Segna una notifica come letta
  Future<void> markAsRead(String token, int id) async {
    try {
      await NotificationRequests().markAsRead(token, id);
      fetchNotificationsByUser(token); // Ricarica le notifiche
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Elimina una notifica
  Future<void> deleteNotification(String token, int id) async {
    try {
      await NotificationRequests().deleteNotification(token, id);
      _notifications.removeWhere((notification) => notification.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Elimina tutte le notifiche contemporaneamente
  // NotificationProvider
  Future<void> deleteAllNotifications(String token) async {
    try {
      await NotificationRequests().deleteAllNotification(token);
      _notifications.clear();
      notifyListeners();  // Notifica la UI per aggiornare immediatamente
    } catch (e) {
      print('Errore nella cancellazione di tutte le notifiche: $e');
    }
  }


}
