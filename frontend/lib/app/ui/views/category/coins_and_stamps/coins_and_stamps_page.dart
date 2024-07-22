import 'package:flutter/material.dart';
import '../../../../components/bottom_navbar.dart';
import '../../../../components/favorite_auction_card.dart';
import '../../../../components/short_auction_card.dart';
import 'all_banknotes.dart';
import 'all_postcards.dart';
import 'all_stamps.dart';
import 'all_bullion.dart';
import 'all_ancient_coins.dart';
import 'all_world_coins.dart';
import 'all_euro_coins.dart';
import 'all_modern_coins.dart';
import '../../../../components/product_detail.dart';

class CoinsAndStampsPage extends StatelessWidget {
  const CoinsAndStampsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monete e francobolli'),
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
                      child: shortAuctionCard(
                        'images/orologio-prova.jpg',
                        'Titolo dell\'asta $index',
                        'Hans Seem',
                        index.isEven ? 'Sta per terminare!' : 'Termina oggi alle ore 12:00',
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40.0),
              buildCategorySection(context, 'Banconote', const AllBanknotesPage()),
              buildCategorySection(context, 'Cartoline', const AllPostcardsPage()),
              buildCategorySection(context, 'Francobolli', const AllStampsPage()),
              buildCategorySection(context, 'Lingotti', const AllBullionPage()),
              buildCategorySection(context, 'Monete antiche', const AllAncientCoinsPage()),
              buildCategorySection(context, 'Monete dal mondo', const AllWorldCoinsPage()),
              buildCategorySection(context, 'Monete di euro', const AllEuroCoinsPage()),
              buildCategorySection(context, 'Monete moderne', const AllModernCoinsPage()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }

  Widget buildCategorySection(BuildContext context, String categoryTitle, Widget categoryPage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              categoryTitle,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => categoryPage),
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
              );
            },
          ),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }
}
