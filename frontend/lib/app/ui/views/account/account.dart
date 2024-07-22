import 'package:bid_hub/app/components/bottom_navbar.dart';
import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class AccountPage extends StatelessWidget {
  final String userName; // Passa il nome dell'utente come parametro

  AccountPage({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
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
            leading: Icon(Icons.shopping_bag),
            title: Text('Ordini'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.orders); // Naviga alla pagina Ordini
            },
          ),
          ListTile(
            leading: Icon(Icons.gavel),
            title: Text('Le mie offerte'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.myBids); // Naviga alla pagina Le mie offerte
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
            leading: const Icon(Icons.shopping_bag),
            title: const Text('All\'asta'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.chooseAuctionType);
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('In elaborazione'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.inProgess);
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
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Messaggi'),
            onTap: () {
              // Naviga alla pagina Messaggi
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifiche'),
            onTap: () {
              // Naviga alla pagina Notifiche
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
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.userProfile);
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
              // Esegui il logout
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 4), // Barra di navigazione
    );
  }
}
