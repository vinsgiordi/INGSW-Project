import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/provider/auction_provider.dart';

class UnsoldPage extends StatefulWidget {
  @override
  _UnsoldPageState createState() => _UnsoldPageState();
}

class _UnsoldPageState extends State<UnsoldPage> {
  @override
  void initState() {
    super.initState();
    _fetchUnsoldAuctions();
  }

  Future<void> _fetchUnsoldAuctions() async {
    final auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    if (token != null) {
      await auctionProvider.fetchUnsoldAuctions(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = Provider.of<AuctionProvider>(context);
    final unsoldAuctions = auctionProvider.unsoldAuctions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Non Venduti'),
      ),
      body: auctionProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : unsoldAuctions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/donna_che_ordina.jpg',
              height: 190,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'Ancora nessun prodotto non venduto.',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: unsoldAuctions.length,
        itemBuilder: (context, index) {
          final auction = unsoldAuctions[index];
          final String reason = auction.bids == null || auction.bids!.isEmpty
              ? 'Nessuna offerta ricevuta'
              : 'Prezzo minimo non raggiunto';

          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        child: auction.productImage != null
                            ? Image.network(auction.productImage!)
                            : Icon(Icons.image, size: 40, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auction.productName ?? 'Prodotto',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              reason,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Prezzo di partenza:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${auction.prezzoIniziale.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
