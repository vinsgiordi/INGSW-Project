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

  Future<void> _loadTokenAndFetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('accessToken');

    if (_token != null) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.fetchNotificationsByUser(_token!);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _deleteNotification(int id) async {
    if (_token != null) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.deleteNotification(_token!, id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifica eliminata.')),
      );
    }
  }

  Future<void> _deleteAllNotifications() async {
    if (_token != null) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.deleteAllNotifications(_token!);
      await notificationProvider.fetchNotificationsByUser(_token!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutte le notifiche sono state cancellate.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifiche'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await _deleteAllNotifications();
            },
            tooltip: 'Cancella tutte le notifiche',
          ),
        ],
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
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];

                return Card(
                  color: notification.isRead ? Colors.white : Colors.grey[200],
                  child: ListTile(
                    title: Text(notification.message),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteNotification(notification.id);
                          },
                        ),
                        if (!notification.isRead)
                          IconButton(
                            icon: const Icon(Icons.mark_email_read, color: Colors.blue),
                            onPressed: () {
                              notificationProvider.markAsRead(_token!, notification.id);
                            },
                          ),
                      ],
                    ),
                    onTap: () {
                      if (notification.isInteractive) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationDetailPage(
                              notification: notification,
                              auctionId: notification.auctionId ?? 0,
                              bidId: notification.bidId ?? 0,
                            ),
                          ),
                        );
                      }
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
