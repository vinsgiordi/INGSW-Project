import 'dart:convert'; // Per decodificare immagini Base64
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../components/product_detail.dart';
import '../../../data/models/auction_model.dart';
import '../../../data/provider/favorites_provider.dart';
import '../../../data/provider/bid_provider.dart';

class AllItemsPage extends StatefulWidget {
  final List<Auction> auctions; // Lista delle aste da visualizzare
  final String pageTitle; // Titolo della pagina
  final bool showAppBar; // Se mostrare o meno l'AppBar

  AllItemsPage({
    required this.auctions,
    this.pageTitle = 'Tutti gli articoli',
    this.showAppBar = true, // Default è true per mostrare l'AppBar
  });

  @override
  _AllItemsPageState createState() => _AllItemsPageState();
}

class _AllItemsPageState extends State<AllItemsPage> {
  bool _isGridView = true; // Stato per la visualizzazione a griglia o lista
  bool isLoading = true;
  String? _currentUserToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadToken();
    });
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUserToken = prefs.getString('accessToken'); // Recupera il token
    setState(() {
      isLoading = false;
    });
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

// Funzione per verificare se una stringa è in formato Base64
  bool isBase64(String value) {
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return value.length % 4 == 0 && base64Regex.hasMatch(value);
  }

// Funzione per caricare l'offerta più alta per un prodotto specifico
  Future<double?> _loadHighestBid(int prodottoId, double prezzoIniziale) async {
    try {
      final bidProvider = Provider.of<BidProvider>(context, listen: false);
      if (_currentUserToken == null) return prezzoIniziale;

      await bidProvider.fetchBidsByProduct(_currentUserToken!, prodottoId);

      if (bidProvider.bids.isNotEmpty) {
        return bidProvider.bids
            .map((bid) => bid.importo)
            .reduce((a, b) => a > b ? a : b);
      } else {
        return prezzoIniziale;
      }
    } catch (e) {
      print('Errore nel caricamento delle offerte: $e');
      return prezzoIniziale; // Se c'è un errore, ritorna il prezzo iniziale
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    List<Auction> limitedAuctions = widget.auctions
        .take(20)
        .toList(); // Limita a 20 elementi o tutti i preferiti

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
        title: Text(widget.pageTitle),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleView,
          ),
        ],
      )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isGridView
          ? buildGridView(limitedAuctions, favoritesProvider)
          : buildListView(limitedAuctions, favoritesProvider),
    );
  }

  Widget buildGridView(
      List<Auction> auctions, FavoritesProvider favoritesProvider) {
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
        final isBase64Image = isBase64(auction.productImage ?? '');

        return FutureBuilder<double?>(
          future: _loadHighestBid(auction.prodottoId, auction.prezzoIniziale),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                  child: Text('Errore nel caricamento del prezzo'));
            } else {
              double prezzoFinale = snapshot.data!;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailPage(auctionId: auction.id),
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
                            child: isBase64Image
                                ? Image.memory(
                              base64Decode(auction.productImage!),
                              height: 150.0,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              auction.productImage ??
                                  'images/300.png',
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
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    auction.productDescription != null
                                        ? auction.productDescription!
                                        .trim()
                                        .length >
                                        30
                                        ? '${auction.productDescription!.trim().substring(0, 30)}...'
                                        : auction.productDescription!
                                        : 'Descrizione non disponibile',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    '€${prezzoFinale.toStringAsFixed(2)}',
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
            }
          },
        );
      },
    );
  }

  Widget buildListView(
      List<Auction> auctions, FavoritesProvider favoritesProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: auctions.length,
      itemBuilder: (context, index) {
        final auction = auctions[index];
        bool isFavorite = favoritesProvider.isFavorite(auction);
        final isBase64Image = isBase64(auction.productImage ?? '');

        return FutureBuilder<double?>(
          future: _loadHighestBid(auction.prodottoId, auction.prezzoIniziale),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                  child: Text('Errore nel caricamento del prezzo'));
            } else {
              double prezzoFinale = snapshot.data!;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailPage(auctionId: auction.id),
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
                            borderRadius: BorderRadius.circular(10.0),
                            child: isBase64Image
                                ? Image.memory(
                              base64Decode(auction.productImage!),
                              height: 150.0,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              'images/300.png',
                              height: 250.0,
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
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  auction.productDescription != null
                                      ? auction.productDescription!
                                      .trim()
                                      .length >
                                      50
                                      ? '${auction.productDescription!.trim().substring(0, 50)}...'
                                      : auction.productDescription!
                                      : 'Descrizione non disponibile',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      '€${prezzoFinale.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (isFavorite) {
                                            favoritesProvider
                                                .removeFavorite(auction);
                                          } else {
                                            favoritesProvider
                                                .addFavorite(auction);
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
            }
          },
        );
      },
    );
  }
}