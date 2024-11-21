import 'package:flutter/material.dart';

class FavoriteImage extends StatefulWidget {
  final String imagePath;
  final bool isFavorite;

  const FavoriteImage({super.key, required this.imagePath, this.isFavorite = false});

  @override
  _FavoriteImageState createState() => _FavoriteImageState();
}

class _FavoriteImageState extends State<FavoriteImage> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0), // Aggiunge spazio intorno all'immagine
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.asset(
              widget.imagePath,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
