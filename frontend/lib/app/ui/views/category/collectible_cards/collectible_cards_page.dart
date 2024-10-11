import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../components/product_detail.dart';
import '../../../../data/provider/favorites_provider.dart';
import '../../../../data/provider/auction_provider.dart';
import '../../../../data/provider/bid_provider.dart'; // Import per le offerte

class CollectibleCardsPage extends StatefulWidget {
  const CollectibleCardsPage({Key? key}) : super(key: key);

  @override
  _CollectibleCardsPageState createState() => _CollectibleCardsPageState();
}

class _CollectibleCardsPageState extends State<CollectibleCardsPage> {
  bool _isGridView = true; // Per alternare tra visualizzazione a griglia e lista
  bool isLoading = true; // Stato di caricamento
  bool isError = false; // Stato di errore
  String? _currentUserToken; // Per gestire il token dell'utente

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAuctions();
  }

  // Funzione per caricare le aste e gestire il token
  Future<void> _loadAuctions() async {
    final auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUserToken = prefs.getString('accessToken');

    if (_currentUserToken != null) {
      try {
        await auctionProvider.fetchAuctionsByCategory(_currentUserToken!, '8'); // Categoria per Carte collezionabili
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        print('Errore nel caricamento delle aste: $e');
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } else {
      print('Token non disponibile');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  // Funzione per recuperare l'offerta più alta per un prodotto specifico
  Future<double?> _loadHighestBid(int prodottoId, double prezzoIniziale) async {
    try {
      final bidProvider = Provider.of<BidProvider>(context, listen: false);
      if (_currentUserToken == null) return prezzoIniziale;

      await bidProvider.fetchBidsByProduct(_currentUserToken!, prodottoId);

      if (bidProvider.bids.isNotEmpty) {
        return bidProvider.bids.map((bid) => bid.importo).reduce((a, b) => a > b ? a : b);
      } else {
        return prezzoIniziale;
      }
    } catch (e) {
      print('Errore nel caricamento delle offerte: $e');
      return prezzoIniziale;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = Provider.of<AuctionProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte collezionabili'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleView,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? const Center(child: Text('Errore nel caricamento delle aste'))
          : auctionProvider.auctions.isEmpty
          ? const Center(child: Text('Nessuna asta disponibile per questa categoria'))
          : _isGridView
          ? buildGridView(auctionProvider.auctions, favoritesProvider)
          : buildListView(auctionProvider.auctions, favoritesProvider),
    );
  }

  // Funzione per creare la visualizzazione a griglia
  Widget buildGridView(List auctions, FavoritesProvider favoritesProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 2 / 3,
      ),
      itemCount: auctions.length,
      itemBuilder: (context, index) {
        final auction = auctions[index];
        bool isFavorite = favoritesProvider.isFavorite(auction);

        return FutureBuilder<double?>(
          future: _loadHighestBid(auction.prodottoId, auction.prezzoIniziale),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            double prezzoFinale = snapshot.data ?? auction.prezzoIniziale;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(auctionId: auction.id),
                  ),
                );
              },
              child: Stack(
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          child: Image.asset(
                            'images/orologio-prova.jpg', // Placeholder image
                            height: 150.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(height: 4.0),
                                Text(
                                  auction.productName ?? 'Nome dell\'asta',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  auction.productDescription != null
                                      ? auction.productDescription!.trim().length > 30
                                      ? '${auction.productDescription!.trim().substring(0, 30)}...'
                                      : auction.productDescription!
                                      : 'Descrizione non disponibile',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Offerta attuale: €${prezzoFinale.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8.0,
                    left: 8.0,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isFavorite) {
                            favoritesProvider.removeFavorite(auction);
                          } else {
                            favoritesProvider.addFavorite(auction);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Funzione per creare la visualizzazione a lista
  Widget buildListView(List auctions, FavoritesProvider favoritesProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: auctions.length,
      itemBuilder: (context, index) {
        final auction = auctions[index];
        bool isFavorite = favoritesProvider.isFavorite(auction);

        return FutureBuilder<double?>(
          future: _loadHighestBid(auction.prodottoId, auction.prezzoIniziale),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            double prezzoFinale = snapshot.data ?? auction.prezzoIniziale;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(auctionId: auction.id),
                  ),
                );
              },
              child: Stack(
                children: [
                  Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          child: Image.asset(
                            'images/orologio-prova.jpg', // Placeholder image
                            height: 200.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 4.0),
                              Text(
                                auction.productName ?? 'Nome dell\'asta',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                auction.productDescription != null
                                    ? auction.productDescription!.trim().length > 30
                                    ? '${auction.productDescription!.trim().substring(0, 30)}...'
                                    : auction.productDescription!
                                    : 'Descrizione non disponibile',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Offerta attuale: €${prezzoFinale.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: isFavorite ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (isFavorite) {
                                          favoritesProvider.removeFavorite(auction);
                                        } else {
                                          favoritesProvider.addFavorite(auction);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
