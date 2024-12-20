import 'dart:convert'; // Per gestire immagini Base64
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../components/product_detail.dart';
import '../../../../data/models/auction_model.dart';
import '../../../../data/provider/bid_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBidsPage extends StatefulWidget {
  @override
  _MyBidsPageState createState() => _MyBidsPageState();
}

class _MyBidsPageState extends State<MyBidsPage> with AutomaticKeepAliveClientMixin {
  bool isLoading = true;
  bool isError = false;
  String? _currentUserToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBids();
    });
  }

  Future<void> _loadBids() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUserToken = prefs.getString('accessToken');

    if (_currentUserToken != null) {
      try {
        await Provider.of<BidProvider>(context, listen: false).fetchBidsByUser(_currentUserToken!);

        // Log delle immagini caricate, una sola volta
        final bids = Provider.of<BidProvider>(context, listen: false).bids;
        for (var bid in bids) {
          final auction = bid.auction;
          if (auction != null) {
            print('Image data: ${auction.productImage}');
          }
        }

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        print('Errore nel caricamento delle offerte: $e');
        if (!mounted) return;
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } else {
      print('Token non disponibile');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  // Verifica se una stringa è in formato Base64
  bool isBase64(String value) {
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return value.length % 4 == 0 && base64Regex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bidProvider = Provider.of<BidProvider>(context);
    final bids = bidProvider.bids;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le mie offerte'),
        automaticallyImplyLeading: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? const Center(child: Text('Errore nel caricamento delle offerte'))
          : bids.isEmpty
          ? const Center(child: Text('Nessuna offerta trovata.'))
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: bids.length,
        itemBuilder: (context, index) {
          final bid = bids[index];
          Auction? auction = bid.auction;
          final isBase64Image = isBase64(auction?.productImage ?? '');

          return GestureDetector(
            onTap: () {
              if (auction != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(auctionId: auction.id),
                  ),
                );
              }
            },
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: auction?.productImage != null && isBase64Image
                      ? Image.memory(
                    base64Decode(auction!.productImage!),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                      : auction?.productImage != null
                      ? Image.network(
                    auction!.productImage!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'images/placeholder.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                      : Image.asset(
                    'images/300.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(auction?.productName ?? 'Titolo non disponibile'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auction?.productDescription ?? 'Descrizione non disponibile'),
                    const SizedBox(height: 4.0),
                    Text(
                      'Offerta: €${bid.importo.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBid(bid.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteBid(int bidId) async {
    try {
      await Provider.of<BidProvider>(context, listen: false).deleteBid(_currentUserToken!, bidId);
      await _loadBids(); // Aggiorna la lista delle offerte
    } catch (e) {
      print('Errore durante l\'eliminazione dell\'offerta: $e');
    }
  }

  @override
  bool get wantKeepAlive => true;
}
