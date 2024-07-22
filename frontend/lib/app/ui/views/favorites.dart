import 'package:flutter/material.dart';
import '../../components/bottom_navbar.dart';
class Favorites extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(
        child: Text('Preferiti Page'),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 3),
    );
}
