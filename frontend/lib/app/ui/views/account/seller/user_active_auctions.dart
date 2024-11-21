import 'dart:convert'; // Per la gestione delle immagini in formato Base64
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../services/storage_service.dart';
import '../../../../components/product_detail.dart';
import '../../../../data/models/auction_model.dart';
import '../../../../data/provider/auction_provider.dart';

class UserActiveAuctionsPage extends StatefulWidget {
  const UserActiveAuctionsPage({Key? key}) : super(key: key);

  @override
  _UserActiveAuctionsPageState createState() => _UserActiveAuctionsPageState();
}

class _UserActiveAuctionsPageState extends State<UserActiveAuctionsPage> {
  final StorageService _storageService = StorageService();
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _fetchUserActiveAuctions();
  }

  Future<void> _fetchUserActiveAuctions() async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        await Provider.of<AuctionProvider>(context, listen: false)
            .fetchUserActiveAuctions(token);
      } else {
        _showSnackbar('Token mancante, per favore effettua il login.');
        setState(() => isError = true);
      }
    } catch (e) {
      print('Errore durante il caricamento delle aste attive: $e');
      setState(() => isError = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool isBase64(String value) {
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return value.length % 4 == 0 && base64Regex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = Provider.of<AuctionProvider>(context);
    final activeAuctions = auctionProvider.activeUserAuctions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le tue Aste Attive'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? const Center(
        child: Text(
          'Errore durante il caricamento delle aste attive.',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      )
          : activeAuctions.isEmpty
          ? const Center(
        child: Text(
          'Al momento non hai aste attive',
          style: TextStyle(fontSize: 18),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: activeAuctions.length,
          itemBuilder: (context, index) {
            final auction = activeAuctions[index];
            return _buildAuctionCard(auction);
          },
        ),
      ),
    );
  }

  Widget _buildAuctionCard(Auction auction) {
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
      child: InkWell(
        onTap: () => _openProductDetail(context, auction.id),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 4),
                    Text(
                      auction.productDescription != null
                          ? auction.productDescription!.length > 30
                          ? '${auction.productDescription!.substring(0, 30)}...'
                          : auction.productDescription!
                          : 'Descrizione non disponibile',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Prezzo Iniziale:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${auction.prezzoIniziale.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteAuction(auction),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openProductDetail(BuildContext context, int auctionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(auctionId: auctionId),
      ),
    );
  }

  Future<void> _deleteAuction(Auction auction) async {
    final token = await _storageService.getAccessToken();
    if (token != null) {
      try {
        final deleted = await Provider.of<AuctionProvider>(context, listen: false)
            .deleteAuction(token, auction.id);
        if (deleted) {
          _showSnackbar('Asta eliminata con successo');
        } else {
          _showSnackbar('Errore durante l\'eliminazione dell\'asta');
        }
      } catch (e) {
        print('Errore durante l\'eliminazione dell\'asta: $e');
        _showSnackbar('Errore durante l\'eliminazione dell\'asta');
      }
    } else {
      _showSnackbar('Token mancante, per favore effettua il login.');
    }
  }
}