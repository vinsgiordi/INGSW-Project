import 'dart:convert'; // Per la gestione delle immagini Base64
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/provider/auction_provider.dart';

class SoldPage extends StatefulWidget {
  @override
  _SoldPageState createState() => _SoldPageState();
}

class _SoldPageState extends State<SoldPage> {
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _fetchSoldAuctions();
  }

  Future<void> _fetchSoldAuctions() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');

      if (token != null) {
        await Provider.of<AuctionProvider>(context, listen: false).fetchSoldAuctions(token);
      }
    } catch (e) {
      print('Errore nel caricamento delle aste vendute: $e');
      setState(() {
        isError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isBase64(String value) {
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return value.length % 4 == 0 && base64Regex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = Provider.of<AuctionProvider>(context);
    final soldAuctions = auctionProvider.auctions.where((auction) {
      return auction.stato == 'completata' &&
          auction.bids != null &&
          auction.bids!.isNotEmpty &&
          auction.bids!.any((bid) => bid.importo >= (auction.prezzoMinimo ?? 0));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prodotti Venduti'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? const Center(
        child: Text(
          'Errore nel caricamento dei dati.',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      )
          : soldAuctions.isEmpty
          ? const Center(
        child: Text(
          'Nessun prodotto venduto.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: soldAuctions.length,
          itemBuilder: (context, index) {
            final auction = soldAuctions[index];
            final highestBid = auction.bids!
                .map((bid) => bid.importo)
                .reduce((a, b) => a > b ? a : b);
            final margin = highestBid - auction.prezzoIniziale;
            final marginColor =
            margin >= 0 ? Colors.green[700] : Colors.red[700];

            final imageWidget = auction.productImage != null
                ? isBase64(auction.productImage!)
                ? Image.memory(
              base64Decode(auction.productImage!),
              fit: BoxFit.cover,
              width: 60,
              height: 60,
            )
                : Image.network(
              auction.productImage!,
              fit: BoxFit.cover,
              width: 60,
              height: 60,
            )
                : Icon(
              Icons.image,
              size: 40,
              color: Colors.grey[600],
            );

            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(vertical: 10),
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
                          child: imageWidget,
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
                              if (auction.bids!.isNotEmpty)
                                Text(
                                  'Venduto a: ${auction.bids![0].utenteNome} ${auction.bids![0].utenteCognome}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Prezzo finale:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${highestBid.toStringAsFixed(2)}€',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Margine di guadagno:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${margin.toStringAsFixed(2)}€',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: marginColor,
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
      ),
    );
  }
}
