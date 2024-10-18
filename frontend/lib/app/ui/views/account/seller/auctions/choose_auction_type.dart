import 'package:flutter/material.dart';
import '../../../../routes/app_routes.dart';

class ChooseAuctionTypePage extends StatelessWidget {
  const ChooseAuctionTypePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scegli il tipo di asta'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.timer, color: Colors.blue),
                  title: const Text('Asta a tempo fisso'),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.fixedTimeAuction);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_offer, color: Colors.green),
                  title: const Text('Asta all\'inglese'),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.englishAuction);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.trending_down, color: Colors.red),
                  title: const Text('Asta al ribasso'),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.reverseAuction);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_off, color: Colors.orange),
                  title: const Text('Asta silenziosa'),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.silentAuction);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'images/auction.png',
              height: 400.0,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
