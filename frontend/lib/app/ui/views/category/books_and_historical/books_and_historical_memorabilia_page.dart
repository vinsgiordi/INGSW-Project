import 'package:flutter/material.dart';
import '../../../../components/bottom_navbar.dart';
import '../../../../components/favorite_auction_card.dart';
import '../../../../components/short_auction_card.dart';
import '../../../../components/product_detail.dart';
import 'all_historical_memorabilia.dart';
import 'all_books.dart';
import 'all_maps.dart';

class BooksAndHistoricalMemorabiliaPage extends StatelessWidget {
  const BooksAndHistoricalMemorabiliaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Libri e cimeli storici'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Aste popolari',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 250.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProductDetailPage()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: shortAuctionCard(
                          'images/orologio-prova.jpg',
                          'Titolo dell\'asta $index',
                          'Hans Seem',
                          index.isEven ? 'Sta per terminare!' : 'Termina oggi alle ore 12:00',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cimeli storici',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllHistoricalMemorabiliaPage()),
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
              SizedBox(
                height: 270.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProductDetailPage()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FavoriteAuctionCard(
                          imagePath: 'images/orologio-prova.jpg',
                          artistName: 'Nome dell\'artista',
                          title: 'Titolo dell\'opera',
                          currentBid: '2.000€',
                          timeRemaining: '3 ore rimanenti',
                          isFavorite: false,
                          onFavoritePressed: () {
                            // Logica per aggiungere ai preferiti
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Libri',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllBooksPage()),
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
              SizedBox(
                height: 270.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProductDetailPage()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FavoriteAuctionCard(
                          imagePath: 'images/orologio-prova.jpg',
                          artistName: 'Nome dell\'artista',
                          title: 'Titolo dell\'opera',
                          currentBid: '1.000€',
                          timeRemaining: '5 ore rimanenti',
                          isFavorite: false,
                          onFavoritePressed: () {
                            // Logica per aggiungere ai preferiti
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mappe',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllMapsPage()),
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
              SizedBox(
                height: 270.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProductDetailPage()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FavoriteAuctionCard(
                          imagePath: 'images/orologio-prova.jpg',
                          artistName: 'Nome dell\'artista',
                          title: 'Titolo dell\'opera',
                          currentBid: '1.000€',
                          timeRemaining: '5 ore rimanenti',
                          isFavorite: false,
                          onFavoritePressed: () {
                            // Logica per aggiungere ai preferiti
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }
}
