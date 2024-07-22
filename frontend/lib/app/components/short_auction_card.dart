import 'package:flutter/material.dart';

Widget shortAuctionCard(String imagePath, String title, String selector, String endingMessage) {
  return Container(
    width: 200.0, // Larghezza delle card
    margin: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          'Selezionato da $selector',
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        Text(
          endingMessage,
          style: const TextStyle(
            color: Colors.blue,
          ),
        ),
      ],
    ),
  );
}
