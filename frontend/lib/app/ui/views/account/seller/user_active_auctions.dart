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

  @override
  void initState() {
    super.initState();
    _fetchUserActiveAuctions();
  }

  Future<void> _fetchUserActiveAuctions() async {
    final token = await _storageService.getAccessToken();
    if (token != null) {
      await Provider.of<AuctionProvider>(context, listen: false).fetchUserActiveAuctions(token);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token mancante, per favore effettua il login.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = Provider.of<AuctionProvider>(context);
    final activeAuctions = auctionProvider.activeUserAuctions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le tue Aste Attive'),
      ),
      body: auctionProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
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
                        backgroundImage: auction.productImage != null
                            ? NetworkImage(auction.productImage!)
                            : null,
                        child: auction.productImage == null
                            ? Icon(Icons.image, size: 40, color: Colors.grey[600])
                            : null,
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
          },
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
      final deleted = await Provider.of<AuctionProvider>(context, listen: false).deleteAuction(token, auction.id);
      if (deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asta eliminata con successo')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante l\'eliminazione dell\'asta')),
        );
      }
    } else {
      // Messaggio se il token è mancante durante l'eliminazione
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token mancante, per favore effettua il login.')),
      );
    }
  }

}
