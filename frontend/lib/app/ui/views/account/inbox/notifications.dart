// ui/views/account/inbox/notifications.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/provider/notification_provider.dart';
import '../../../../components/notification_detail.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchNotifications();
  }

  // Funzione per caricare il token e recuperare le notifiche
  Future<void> _loadTokenAndFetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('accessToken');

    if (_token != null) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.fetchNotificationsByUser(_token!);
    } else {
      // Se non c'è il token, reindirizza l'utente alla pagina di login
      Navigator.pushReplacementNamed(context, '/login'); // Rotta per il login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifiche'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notificationProvider.notifications.isEmpty) {
            return const Center(child: Text('Nessuna notifica disponibile'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0), // Aggiungi padding per lo spazio tra i bordi
            child: ListView.builder(
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return Card(
                  color: notification.letto ? Colors.white : Colors.grey[200], // Cambia colore di background per non lette
                  child: ListTile(
                    title: Text(notification.messaggio),
                    trailing: notification.letto
                        ? const Icon(Icons.check, color: Colors.green)
                        : IconButton(
                      icon: const Icon(Icons.mark_email_read, color: Colors.blue),
                      onPressed: () {
                        notificationProvider.markAsRead(_token!, notification.id);
                      },
                    ),
                    onTap: () {
                      // Naviga al componente NotificationDetailPage quando si clicca su una notifica
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationDetailPage(notification: notification),
                        ),
                      );
                    },
                    onLongPress: () {
                      notificationProvider.deleteNotification(_token!, notification.id);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
