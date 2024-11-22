import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/storage_service.dart';

import '../../../components/bottom_navbar.dart';
import '../../../components/auction_card.dart';
import '../../../components/favorite_image.dart';
import '../../../components/short_auction_card.dart';
import '../../../components/recommended_category.dart';
import '../../../components/product_detail.dart';

import '../../../data/provider/auction_provider.dart';
import '../../../data/provider/category_provider.dart';
import '../../../data/provider/favorites_provider.dart';
import '../../../data/provider/bid_provider.dart';

import '../category/art/art_page.dart';
import '../category/jewels/jewelry_page.dart';
import '../category/watches/watches_page.dart';
import '../category/fashions/fashions_page.dart';
import '../category/coins_and_stamps/coins_and_stamps_page.dart';
import '../category/comics_and_animations/comics_and_animation_page.dart';

import 'all_items_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _currentUserToken;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}";
  }

  String _getMonthName(int month) {
    const months = [
      "gennaio", "febbraio", "marzo", "aprile", "maggio", "giugno",
      "luglio", "agosto", "settembre", "ottobre", "novembre", "dicembre"
    ];
    return months[month - 1];
  }


  Future<void> _initializeData() async {
    _currentUserToken = await StorageService().getAccessToken();
    print("Token: $_currentUserToken");

    if (_currentUserToken != null) {
      final auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

      // Carica le aste da mostrare nel carosello
      List<String> categoryIds = ['1', '2', '3']; // IDs delle categorie da includere nel carosello
      await auctionProvider.fetchCarouselAuctions(_currentUserToken!, categoryIds);

      // Recupero delle aste attive
      await auctionProvider.fetchActiveAuctions(_currentUserToken!);
      print("Aste attive: ${auctionProvider.activeAuctions.length}");

      // Recupero delle aste che terminano presto
      await auctionProvider.fetchAuctionsEndingSoon(_currentUserToken!);
      print("Aste che terminano a breve: ${auctionProvider.endingSoonAuctions.length}");

      // Recupero delle aste per tipo dal backend
      await auctionProvider.fetchAuctionByType(_currentUserToken!);
      print("Aste per tipo: ${auctionProvider.auctionType.length}");

      // Recupero delle categorie
      await categoryProvider.fetchRecommendedCategories();
      print("Categorie recuperate: ${categoryProvider.categories.length}");
    } else {
      print("Token non disponibile");
    }
  }

  // Funzione per caricare l'offerta più alta per un prodotto specifico
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
      return prezzoIniziale; // Se c'è un errore, ritorna il prezzo iniziale
    }
  }

  void _navigateToCategoryPage(BuildContext context, String categoryName) {
    Widget page;

    switch (categoryName) {
      case 'Arte':
        page = ArtPage();
        break;
      case 'Gioielli':
        page = const JewelryPage();
        break;
      case 'Orologi da polso':
        page = const WatchesPage();
        break;
      case 'Moda':
        page = const FashionsPage();
        break;
      case 'Monete e francobolli':
        page = const CoinsAndStampsPage();
        break;
      case 'Fumetti e animazione':
        page = const ComicsAndAnimationPage();
        break;
      default:
        page = ArtPage(); // Default page in case the category doesn't match
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Recupera il provider AuctionProvider
    final auctionProvider = Provider.of<AuctionProvider>(context);

    // Mappa che associa le categorie ai loghi corrispondenti
    Map<String, String> categoryLogos = {
      'Arte': 'images/art_logo.jpg',
      'Gioielli': 'images/jewelry_logo.jpg',
      'Orologi da polso': 'images/watches_logo.jpg',
      'Moda': 'images/fashion_logo.jpg',
      'Monete e francobolli': 'images/coins_stamp_logo.jpg',
      'Fumetti e animazione': 'images/comics_animation_logo.jpg',
    };

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Consumer<AuctionProvider>(
                    builder: (context, auctionProvider, child) {
                      if (auctionProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (auctionProvider.carouselAuctions.isEmpty) {
                        return const Center(child: Text('Nessuna asta disponibile'));
                      }

                      return CarouselSlider(
                        options: CarouselOptions(
                          height: double.infinity,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.8,
                        ),
                        items: auctionProvider.carouselAuctions.map((auction) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProductDetailPage(auctionId: auction.id)),
                              );
                            },
                            child: auctionCard(
                              auction.productImage ?? 'images/300.png',
                              auction.productName ?? 'Titolo dell\'asta',
                              'Termina il ${formatDate(auction.dataScadenza)} ${auction.dataScadenza.hour.toString().padLeft(2, '0')}:${auction.dataScadenza.minute.toString().padLeft(2, '0')}',
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'La tua selezione quotidiana',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AllItemsPage(
                            auctions: auctionProvider.activeAuctions,
                            pageTitle: 'Tutti gli articoli',
                          )),
                        );
                      },
                      child: const Text(
                        'Visualizza tutto',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Consumer2<AuctionProvider, FavoritesProvider>(
                  builder: (context, auctionProvider, favoritesProvider, child) {
                    if (auctionProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (auctionProvider.activeAuctions.isEmpty) {
                      return const Center(child: Text('Nessuna asta disponibile'));
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3 / 4,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: auctionProvider.activeAuctions.length < 9
                          ? auctionProvider.activeAuctions.length
                          : 9,
                      itemBuilder: (context, index) {
                        final auction = auctionProvider.activeAuctions[index];
                        bool isFavorite = favoritesProvider.isFavorite(auction);

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
                              FavoriteImage(
                                imagePath: auction.productImage ?? 'images/300.png',
                              ),
                              Positioned(
                                top: 3.0,
                                left: 0.0,
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
                ),
              ),
              const SizedBox(height: 25.0), // Spazio tra le sezioni
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Aste che terminano a breve',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 250.0, // Altezza per contenere le card
                child: Consumer<AuctionProvider>(
                  builder: (context, auctionProvider, child) {
                    if (auctionProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (auctionProvider.endingSoonAuctions.isEmpty) {
                      return const Center(child: Text('Nessuna asta disponibile'));
                    }

                    final limitedAuctions = auctionProvider.endingSoonAuctions.take(10).toList();

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: limitedAuctions.length,
                      itemBuilder: (context, index) {
                        final auction = limitedAuctions[index];

                        print('Auction ID: ${auction.id}, Seller Name: ${auction.sellerName}');

                        return FutureBuilder<double?>(
                          future: _loadHighestBid(auction.prodottoId, auction.prezzoIniziale),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError || !snapshot.hasData) {
                              return const Center(child: Text('Errore nel caricamento'));
                            } else {
                              final prezzoFinale = snapshot.data!;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(auctionId: auction.id),
                                    ),
                                  );
                                },
                                child: shortAuctionCard(
                                  auction.productImage ?? 'images/300.png',
                                  auction.productName ?? 'Titolo dell\'asta',
                                  auction.sellerName ?? 'Nome venditore', // Mostra il nome del venditore
                                  '€${prezzoFinale.toStringAsFixed(2)}',
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 25.0), // Spazio tra le sezioni
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Categorie consigliate',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child) {
                    if (categoryProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (categoryProvider.categories.isEmpty) {
                      return const Center(child: Text('Nessuna categoria disponibile'));
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: categoryProvider.categories.length < 6
                          ? categoryProvider.categories.length
                          : 6, // Mostra solo le prime 6 categorie
                      itemBuilder: (context, index) {
                        final category = categoryProvider.categories[index];
                        final logoPath = categoryLogos[category.nome] ?? 'images/logo.png'; // Logo predefinito se non trovato
                        return GestureDetector(
                          onTap: () {
                            _navigateToCategoryPage(context, category.nome);
                          },
                          child: recommendedCategory(
                            logoPath,
                            category.nome,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }
}