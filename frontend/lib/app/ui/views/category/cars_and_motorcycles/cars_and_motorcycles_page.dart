import 'package:flutter/material.dart';
import '../../../../components/bottom_navbar.dart';
import '../../../../components/favorite_auction_card.dart';
import '../../../../components/short_auction_card.dart';
import '../../../../components/product_detail.dart';
import 'all_classic_cars.dart';
import 'all_motorcycles_and_water_scooters.dart';

class CarsAndMotorcyclesPage extends StatelessWidget {
  const CarsAndMotorcyclesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto e Moto'),
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
                          MaterialPageRoute(
                            builder: (context) => const ProductDetailPage(),
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
              const SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Auto d\'epoca',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllClassicCarsPage()),
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
                          MaterialPageRoute(
                            builder: (context) => const ProductDetailPage(),
                          ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Moto e scooter d\'acqua',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllMotorcyclesAndWaterScootersPage()),
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
                height: 300.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductDetailPage(),
                          ),
                        );
                      },
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
