import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../services/storage_service.dart';
import '../../../../data/models/auction_model.dart';
import '../../../../data/provider/auction_provider.dart';

class UserActiveAuctionsPage extends StatefulWidget {
  const UserActiveAuctionsPage({Key? key}) : super(key: key);

  @override
  _UserActiveAuctionsPageState createState() => _UserActiveAuctionsPageState();
}

class _UserActiveAuctionsPageState extends State<UserActiveAuctionsPage> {
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _fetchUserActiveAuctions();
  }

  Future<void> _fetchUserActiveAuctions() async {
    final token = await _storageService.getAccessToken();
    if (token != null) {
      await Provider.of<AuctionProvider>(context, listen: false).fetchUserActiveAuctions(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = Provider.of<AuctionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le tue Aste Attive'),
      ),
      body: auctionProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildUserAuctionList(context, auctionProvider),
    );
  }

  Widget _buildUserAuctionList(BuildContext context, AuctionProvider auctionProvider) {
    final activeAuctions = auctionProvider.activeUserAuctions;

    if (activeAuctions.isEmpty) {
      return const Center(
        child: Text('Al momento non hai aste attive'),
      );
    } else {
      return ListView.builder(
        itemCount: activeAuctions.length,
        itemBuilder: (context, index) {
          final auction = activeAuctions[index];

          return ListTile(
            title: Text(auction.titolo ?? "Titolo non disponibile"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Descrizione: ${auction.descrizione ?? "Non disponibile"}"),
                Text("Prezzo Iniziale: €${auction.prezzoIniziale.toStringAsFixed(2)}"),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteAuction(auction),
            ),
          );
        },
      );
    }
  }

  Future<void> _deleteAuction(Auction auction) async {
    final token = await _storageService.getAccessToken();
    if (token != null) {
      final deleted = await Provider.of<AuctionProvider>(context, listen: false).deleteAuction(token, auction.id);
      if (deleted) {
        _fetchUserActiveAuctions();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asta eliminata con successo')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante l\'eliminazione dell\'asta')),
        );
      }
    }
  }
}
