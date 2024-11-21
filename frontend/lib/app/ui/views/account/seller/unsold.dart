import 'dart:convert'; // Per la gestione delle immagini Base64
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/provider/auction_provider.dart';

class UnsoldPage extends StatefulWidget {
  @override
  _UnsoldPageState createState() => _UnsoldPageState();
}

class _UnsoldPageState extends State<UnsoldPage> {
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _fetchUnsoldAuctions();
  }

  Future<void> _fetchUnsoldAuctions() async {
    try {
      final auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');
      if (token != null) {
        await auctionProvider.fetchUnsoldAuctions(token);
      }
    } catch (e) {
      print('Errore nel caricamento delle aste non vendute: $e');
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
    final unsoldAuctions = auctionProvider.unsoldAuctions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Non Venduti'),
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
          : unsoldAuctions.isEmpty
          ? const Center(
        child: Text(
          'Ancora nessun prodotto non venduto.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: unsoldAuctions.length,
        itemBuilder: (context, index) {
          final auction = unsoldAuctions[index];
          final String reason = auction.bids == null || auction.bids!.isEmpty
              ? 'Nessuna offerta ricevuta'
              : 'Prezzo minimo non raggiunto';

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