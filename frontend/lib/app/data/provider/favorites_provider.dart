import 'package:flutter/material.dart';
import '../models/auction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesProvider with ChangeNotifier {
  List<Auction> _favoriteAuctions = [];
  String? _userToken; // Memorizza il token dell'utente corrente

  List<Auction> get favoriteAuctions => _favoriteAuctions;

  // Imposta il token dell'utente (chiamato quando l'utente si logga)
  void setUserToken(String token) {
    _userToken = token;
  }

  // Aggiungi un'asta ai preferiti
  void addFavorite(Auction auction) {
    if (auction.productName != null && auction.productDescription != null) {
      _favoriteAuctions.add(auction);
      _saveFavorites(); // Salva nei preferiti
      notifyListeners();
    } else {
      print("Errore: alcuni campi dell'asta sono nulli.");
    }
  }

  // Salva i preferiti in SharedPreferences con chiave specifica per l'utente
  Future<void> _saveFavorites() async {
    if (_userToken == null) return; // Se il token è null, non fare nulla
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedFavorites = _favoriteAuctions.map((auction) => json.encode(auction.toJson())).toList();
    await prefs.setStringList('favorite_auctions_$_userToken', encodedFavorites); // Salva con chiave specifica
  }

  // Carica i preferiti da SharedPreferences per l'utente corrente
  Future<void> loadFavoritesForUser() async {
    if (_userToken == null) return; // Se il token è null, non fare nulla
    final prefs = await SharedPreferences.getInstance();
    List<String>? encodedFavorites = prefs.getStringList('favorite_auctions_$_userToken');
    if (encodedFavorites != null) {
      _favoriteAuctions = encodedFavorites.map((auction) => Auction.fromJson(json.decode(auction))).toList();
    }
    notifyListeners();
  }

  // Rimuovi un'asta dai preferiti
  void removeFavorite(Auction auction) {
    _favoriteAuctions.removeWhere((item) => item.id == auction.id);
    _saveFavorites(); // Aggiorna i preferiti salvati
    notifyListeners();
  }

  // Verifica se un'asta è nei preferiti
  bool isFavorite(Auction auction) {
    return _favoriteAuctions.any((item) => item.id == auction.id);
  }

  // Pulisce i preferiti dal provider e da SharedPreferences (chiamato durante il logout)
  Future<void> clearFavorites() async {
    _favoriteAuctions.clear();
    notifyListeners();
    if (_userToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favorite_auctions_$_userToken'); // Rimuovi i preferiti specifici dell'utente
    }
  }
}
