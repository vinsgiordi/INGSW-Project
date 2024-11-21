import 'dart:convert'; // Per decodificare le immagini Base64
import 'package:flutter/material.dart';

class FavoriteImage extends StatefulWidget {
  final String imagePath; // Può essere un'immagine Base64 o un asset
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

  bool _isBase64(String value) {
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return value.length % 4 == 0 && base64Regex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final isBase64 = _isBase64(widget.imagePath);

    return Padding(
      padding: const EdgeInsets.all(2.0), // Aggiunge spazio intorno all'immagine
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: isBase64
                ? Image.memory(
              base64Decode(widget.imagePath),
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Image.asset(
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