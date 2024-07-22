import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../components/bottom_navbar.dart';
import '../../../components/auction_card.dart';
import '../../../components/favorite_image.dart';
import '../../../components/short_auction_card.dart';
import '../../../components/recommended_category.dart';
import 'all_items_page.dart';
import '../../../components/product_detail.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
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
                  aspectRatio: 16 / 9, // Adatta l'aspect ratio come necessario
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: double.infinity,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.8,
                    ),
                    items: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProductDetailPage()),
                          );
                        },
                        child: auctionCard(
                          'images/orologio-prova.jpg',
                          'Asta di Land Rover Lancia Martini',
                          '5 - 21 July 2024',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProductDetailPage()),
                          );
                        },
                        child: auctionCard(
                          'images/orologio-prova.jpg',
                          'Asta di Apple II',
                          '5 - 21 July 2024',
                        ),
                      ),
                    ],
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
                          MaterialPageRoute(builder: (context) => AllItemsPage()),
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
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: 9, // 9 elementi per la selezione quotidiane
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductDetailPage(), // Naviga alla pagina di dettaglio
                          ),
                        );
                      },
                      child: const FavoriteImage(
                        imagePath: 'images/orologio-prova.jpg',
                      ),
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
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Numero di aste da mostrare
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductDetailPage(), // Naviga alla pagina di dettaglio
                          ),
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
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: 6, // Numero di categorie consigliate
                  itemBuilder: (context, index) {
                    return recommendedCategory(
                      'images/orologio-prova.jpg',
                      'Categoria $index',
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
