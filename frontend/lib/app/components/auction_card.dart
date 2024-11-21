import 'dart:convert';
import 'package:flutter/material.dart';

Widget auctionCard(String imagePath, String title, String subtitle) {
  bool isBase64 = RegExp(r'^[A-Za-z0-9+/]+={0,2}$').hasMatch(imagePath);

  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
          child: isBase64
              ? Image.memory(
            base64Decode(imagePath),
            height: 150.0,
            width: double.infinity,
            fit: BoxFit.cover,
          )
              : Image.asset(
            imagePath,
            height: 150.0,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    ),
  );
}