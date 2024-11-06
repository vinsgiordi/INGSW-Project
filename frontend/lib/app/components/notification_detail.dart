import 'package:flutter/material.dart';
import '../data/models/notification_model.dart';
import '../data/models/auction_model.dart';
import '../data/provider/auction_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationDetailPage extends StatefulWidget {
  final NotificationModel notification;
  final int auctionId;
  final int bidId;

  const NotificationDetailPage({
    required this.notification,
    required this.auctionId,
    required this.bidId,
  });

  @override
  _NotificationDetailPageState createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  Future<Auction?>? auctionFuture;

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') ?? '';
  }

  Future<Auction?> _loadAuction() async {
    final token = await _getToken();

    // Aggiungi un controllo per verificare che l'ID non sia nullo o zero
    if (widget.auctionId == 0) {
      print("ID asta non valido: ${widget.auctionId}");
      return null;  // Evita il caricamento dell'asta e restituisci null
    }

    try {
      Auction? loadedAuction = await Provider.of<AuctionProvider>(context, listen: false)
          .fetchAuctionById(token, widget.auctionId);
      return loadedAuction;
    } catch (e) {
      print('Errore nel caricamento dell\'asta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nel caricamento dell\'asta')),
      );
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    auctionFuture = _loadAuction(); // Avvia il caricamento dell'asta
  }

  void _acceptBid(Auction auction) async {
    final token = await _getToken();
    try {
      await Provider.of<AuctionProvider>(context, listen: false)
          .acceptBidForSilentAuction(token, widget.auctionId, widget.bidId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offerta accettata con successo.')),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nell\'accettazione dell\'offerta: $error')),
      );
    }
  }

  void _rejectAllBids(Auction auction) async {
    final token = await _getToken();
    try {
      await Provider.of<AuctionProvider>(context, listen: false)
          .rejectAllBidsForSilentAuction(token, widget.auctionId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offerta rifiutata con successo')),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel rifiuto delle offerte: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Notifica'),
      ),
      body: FutureBuilder<Auction?>(
        future: auctionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Errore nel caricamento dei dettagli dell\'asta'));
          } else {
            final auction = snapshot.data!;
            final bool isBidNotification = widget.bidId != 0 && auction.stato == 'attiva' && auction.tipo == 'silenziosa';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.notification.message,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 32),
                  if (isBidNotification)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _acceptBid(auction),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text(
                            'Accetta Offerta',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _rejectAllBids(auction),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Rifiuta Offerta',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
