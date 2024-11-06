import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/provider/user_provider.dart';
import '../../../data/provider/notification_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../components/bottom_navbar.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.nome ?? 'Utente';

    return Scaffold(
      body: FutureBuilder(
        future: _checkTokenAndLoadNotifications(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == false) {
            return const Center(child: Text('Errore nel caricamento. Effettua il login.'));
          }

          return ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Ciao $userName',
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // SEZIONE ACQUIRENTE
              const ListTile(
                title: Text(
                  'ACQUISTA',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text('Ordini'),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.orders);
                },
              ),
              ListTile(
                leading: const Icon(Icons.gavel),
                title: const Text('Le mie offerte'),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.myBids);
                },
              ),

              // SEZIONE VENDITORE
              const ListTile(
                title: Text(
                  'VENDI',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add_business_rounded),
                title: const Text('Crea asta'),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.chooseAuctionType);
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text('All\'asta'),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.userAuctions);
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('Venduti'),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.sold);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Non venduti'),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.unsold);
                },
              ),

              // MESSAGGISTICA
              const ListTile(
                title: Text(
                  'POSTA IN ARRIVO',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  final int unreadCount = notificationProvider.notifications
                      .where((notification) => !notification.isRead)
                      .length;
                  return ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifiche'),
                    trailing: unreadCount > 0
                        ? CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                        : null,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    },
                  );
                },
              ),
              // ACCOUNT
              const ListTile(
                title: Text(
                  'ACCOUNT',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Impostazioni dell\'account'),
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? token = prefs.getString('accessToken');
                  if (token != null) {
                    Navigator.pushNamed(context, AppRoutes.userProfile);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Token non disponibile, effettua il login.')),
                    );
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Indirizzi'),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.addresses);
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Pagamenti'),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.payments);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Chiudi sessione'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 4),
    );
  }

  // Funzione che carica il token e recupera le notifiche
  Future<bool> _checkTokenAndLoadNotifications(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    if (token == null) {
      return false;
    }

    // Recupera le notifiche usando NotificationProvider
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.fetchNotificationsByUser(token);
    return true;
  }
}
