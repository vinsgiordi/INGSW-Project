import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/product_detail.dart';
import '../../../data/models/auction_model.dart';
import '../../../data/provider/favorites_provider.dart';
import '../../../data/provider/bid_provider.dart';
import '../../../components/bottom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool isLoading = true;
  bool isError = false;
  String? _currentUserToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  // Carica i preferiti dell'utente con il token associato
  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUserToken = prefs.getString('accessToken'); // Recupera il token da SharedPreferences

    if (_currentUserToken != null) {
      try {
        await Provider.of<FavoritesProvider>(context, listen: false)
            .loadFavoritesForUser(); // Carica i preferiti senza richiedere un token
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        print('Errore nel caricamento dei preferiti: $e');
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

  // Carica l'offerta più alta
  Future<double?> _loadHighestBid(String token, int prodottoId, double prezzoIniziale) async {
    try {
      final bidProvider = Provider.of<BidProvider>(context, listen: false);
      await bidProvider.fetchBidsByProduct(token, prodottoId);

      if (bidProvider.bids.isNotEmpty) {
        return bidProvider.bids.map((bid) => bid.importo).reduce((a, b) => a > b ? a : b);
      } else {
        return prezzoIniziale; // Ritorna il prezzo iniziale se non ci sono offerte
      }
    } catch (e) {
      print('Error fetching bids: $e');
      return prezzoIniziale; // In caso di errore, ritorna il prezzo iniziale
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    List<Auction> favoriteAuctions = favoritesProvider.favoriteAuctions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('I tuoi preferiti'),
        automaticallyImplyLeading: false, // Nasconde la freccia di ritorno
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? const Center(child: Text('Errore nel caricamento dei preferiti'))
          : favoriteAuctions.isEmpty
          ? const Center(child: Text('Nessun preferito trovato.'))
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: favoriteAuctions.length,
        itemBuilder: (context, index) {
          final auction = favoriteAuctions[index];

          return FutureBuilder<double?>(
            future: _loadHighestBid(
                _currentUserToken ?? '', auction.prodottoId, auction.prezzoIniziale),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Center(
                    child: Text('Errore nel caricamento dell\'offerta'));
              } else {
                double prezzoFinale = snapshot.data!;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(auctionId: auction.id),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          auction.productImage ?? 'https://via.placeholder.com/150',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(auction.productName ?? 'Titolo non disponibile'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auction.productDescription ??
                              'Descrizione non disponibile'),
                          const SizedBox(height: 4.0),
                          Text(
                            '€${prezzoFinale.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            favoritesProvider.removeFavorite(auction);
                          });
                        },
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar:
      const BottomNavBar(selectedIndex: 3), // Navbar per navigare tra le sezioni
    );
  }
}
