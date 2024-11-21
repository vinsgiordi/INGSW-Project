import 'package:bid_hub/app/ui/views/category/archaeologies/archaeology_page.dart';
import 'package:bid_hub/app/ui/views/category/art/art_page.dart';
import 'package:bid_hub/app/ui/views/category/books_and_historical/books_and_historical_memorabilia_page.dart';
import 'package:bid_hub/app/ui/views/category/cars_and_motorcycles/cars_and_motorcycles_page.dart';
import 'package:bid_hub/app/ui/views/category/coins_and_stamps/coins_and_stamps_page.dart';
import 'package:bid_hub/app/ui/views/category/collectible_cards/collectible_cards_page.dart';
import 'package:bid_hub/app/ui/views/category/comics_and_animations/comics_and_animation_page.dart';
import 'package:bid_hub/app/ui/views/category/fashions/fashions_page.dart';
import 'package:bid_hub/app/ui/views/category/jewels/jewelry_page.dart';
import 'package:bid_hub/app/ui/views/category/music_film/music_film_and_cameras_page.dart';
import 'package:bid_hub/app/ui/views/category/sports/sports_page.dart';
import 'package:bid_hub/app/ui/views/category/toys_and_models/toys_and_models_page.dart';
import 'package:bid_hub/app/ui/views/category/watches/watches_page.dart';
import 'package:flutter/material.dart';
import '../../../components/bottom_navbar.dart';

class CategoriesPage extends StatelessWidget {
  static final List<Map<String, dynamic>> categories = [
    {"id": 1, "name": "Arte", "color": Colors.green.shade200, "page": const ArtPage()},
    {"id": 2, "name": "Gioielli", "color": Colors.blueGrey.shade200, "page": const JewelryPage()},
    {"id": 3, "name": "Orologi da polso", "color": Colors.teal.shade200, "page": const WatchesPage()},
    {"id": 4, "name": "Moda", "color": Colors.pink.shade200, "page": const FashionsPage()},
    {"id": 5, "name": "Monete e francobolli", "color": Colors.purple.shade200, "page": const CoinsAndStampsPage()},
    {"id": 6, "name": "Fumetti e animazione", "color": Colors.cyan.shade200, "page": const ComicsAndAnimationPage()},
    {"id": 7, "name": "Auto e moto", "color": Colors.brown.shade200, "page": const CarsAndMotorcyclesPage()},
    {"id": 8, "name": "Carte collezionabili", "color": Colors.orange.shade200, "page": const CollectibleCardsPage()},
    {"id": 9, "name": "Giocattoli e modellini", "color": Colors.deepOrange.shade200, "page": const ToysAndModelsPage()},
    {"id": 10, "name": "Archeologia e reperti", "color": Colors.brown.shade200, "page": ArchaeologyPage()},
    {"id": 11, "name": "Sport", "color": Colors.yellow.shade200, "page": const SportsPage()},
    {"id": 12, "name": "Musica, film e fotocamere", "color": Colors.red.shade200, "page": const MusicFilmAndCamerasPage()},
    {"id": 13, "name": "Libri e cimeli storici", "color": Colors.green.shade200, "page":  const BooksAndHistoricalMemorabiliaPage()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Rimuove la freccia
        title: const Text(
          'Categorie',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: categories[index]["color"],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: Text(
                    categories[index]["name"],
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward, color: Colors.black),
                  onTap: () {
                    // Naviga alla pagina della categoria specifica
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => categories[index]["page"]),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }
}
