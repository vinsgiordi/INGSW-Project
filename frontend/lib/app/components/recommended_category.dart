import 'package:flutter/material.dart';

Widget recommendedCategory(String imagePath, String categoryName) {
  return Column(
    children: <Widget>[
      ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.asset(
          imagePath,
          height: 150.0,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: 8.0), // Spazio tra immagine e titolo
      Text(
        categoryName,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}
