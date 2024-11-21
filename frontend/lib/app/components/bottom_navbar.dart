import 'package:flutter/material.dart';
import 'package:bid_hub/app/ui/views/home/home.dart';
import 'package:bid_hub/app/ui/views/category/categories.dart';
import 'package:bid_hub/app/ui/views/others/search.dart';
import 'package:bid_hub/app/ui/views/others/favorites.dart';
import 'package:bid_hub/app/ui/views/account/account.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;

  const BottomNavBar({required this.selectedIndex});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _onItemTapped(int index) {
    if (index != widget.selectedIndex) {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Home()));
          break;
        case 1:
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CategoriesPage()));
          break;
        case 2:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SearchPage()));
          break;
        case 3:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => FavoritesPage()));
          break;
        case 4:
          Navigator.pushReplacement(
              context, MaterialPageRoute(
              builder: (context) => AccountPage()));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categorie',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Cerca',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Preferiti',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Account',
        ),
      ],
      currentIndex: widget.selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
    );
  }
}
