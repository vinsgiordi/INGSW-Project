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
  Auction? auction;
  bool isLoading = true;

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') ?? '';
  }

  void _acceptBid() async {
    final token = await _getToken();
    Provider.of<AuctionProvider>(context, listen: false)
        .acceptBidForSilentAuction(token, widget.auctionId, widget.bidId)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offerta accettata con successo.')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nell\'accettazione dell\'offerta: $error')),
      );
    });
  }

  void _rejectAllBids() async {
    final token = await _getToken();
    Provider.of<AuctionProvider>(context, listen: false)
        .rejectAllBidsForSilentAuction(token, widget.auctionId)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutte le offerte rifiutate con successo.')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel rifiuto delle offerte: $error')),
      );
    });
  }

  Future<void> _loadAuction() async {
    final token = await _getToken();
    print('Auction ID ricevuto: ${widget.auctionId}');

    try {
      Auction? loadedAuction = await Provider.of<AuctionProvider>(context, listen: false)
          .fetchAuctionById(token, widget.auctionId);
      if (loadedAuction != null) {
        print('Auction loaded successfully: ${loadedAuction.id}');
      } else {
        print('No auction found for ID: ${widget.auctionId}');
      }
      setState(() {
        auction = loadedAuction;
        isLoading = false;
      });
    } catch (e) {
      print('Errore nel caricamento dell\'asta: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAuction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Notifica'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : auction == null
          ? const Center(child: Text('Asta non trovata'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.notification.message,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            // Mostra i pulsanti solo se l'asta è di tipo silenziosa e in stato attivo
            if (auction!.tipo == 'silenziosa' && auction!.stato == 'attiva')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _acceptBid,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Accetta Offerta',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _rejectAllBids,
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
      ),
    );
  }
}
