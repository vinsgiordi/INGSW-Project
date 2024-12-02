import 'package:flutter/material.dart';
import '../models/auction_model.dart';
import '../requests/search_request.dart';

class SearchProvider with ChangeNotifier {
  List<Auction> _searchResults = [];
  bool _isLoading = false;

  List<Auction> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  // Funzione per eseguire la ricerca con query e categoryId
  Future<void> performSearch(String token, {String? query, String? categoryId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Chiamata alla funzione di ricerca
      _searchResults = await SearchRequests().searchAuctions(token, query: query, categoryId: categoryId);
    } catch (e) {
      print('Errore nella ricerca: $e');
      _searchResults = []; // Reset se c'è un errore
    }

    _isLoading = false;
    notifyListeners();
  }

  // Funzione per pulire i risultati della ricerca
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
}
