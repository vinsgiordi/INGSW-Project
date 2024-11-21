import 'package:flutter/material.dart';

class FavoriteAuctionCard extends StatefulWidget {
  final String imagePath;
  final String artistName;
  final String title;
  final String currentBid;
  final String timeRemaining;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const FavoriteAuctionCard({
    Key? key,
    required this.imagePath,
    required this.artistName,
    required this.title,
    required this.currentBid,
    required this.timeRemaining,
    this.isFavorite = false,
    required this.onFavoritePressed,
  }) : super(key: key);

  @override
  _FavoriteAuctionCardState createState() => _FavoriteAuctionCardState();
}

class _FavoriteAuctionCardState extends State<FavoriteAuctionCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  widget.imagePath,
                  height: 150.0,
                  width: 150.0,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8.0,
                left: 8.0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    widget.onFavoritePressed();
                  },
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0), // Spazio tra immagine e titolo
          Text(
            widget.artistName,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Offerta attuale: ${widget.currentBid}',
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Mancano ${widget.timeRemaining}',
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
