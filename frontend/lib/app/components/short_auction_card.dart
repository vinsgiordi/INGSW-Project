import 'dart:convert';
import 'package:flutter/material.dart';

Widget shortAuctionCard(String imagePath, String title, String selector, String endingMessage) {
  bool isBase64(String value) {
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return value.length % 4 == 0 && base64Regex.hasMatch(value);
  }

  final isBase64Image = isBase64(imagePath);

  return Container(
    width: 200.0, // Larghezza delle card
    margin: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 120.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0), // Angoli arrotondati per le immagini
            image: DecorationImage(
              image:isBase64Image
              ? MemoryImage(base64Decode(imagePath))
                  : AssetImage(imagePath) as ImageProvider,
              fit: BoxFit.cover,
            ),
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
          'Selezionato da $selector', // Nome del venditore
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