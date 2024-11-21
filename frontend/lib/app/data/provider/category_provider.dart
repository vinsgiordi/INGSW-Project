import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../requests/category_request.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  // Recupera le categorie
  Future<void> fetchRecommendedCategories() async {
    _isLoading = true;
    notifyListeners();  // Notifica gli ascoltatori che è in corso il caricamento

    try {
      // Recupera tutte le categorie dall'API
      _categories = await CategoryRequests().getAllCategories();
      print('Categorie recuperate: ${_categories.length}');
    } catch (e) {
      print('Errore nel recuperare le categorie: $e');
    }

    _isLoading = false;
    notifyListeners();  // Notifica gli ascoltatori che il caricamento è terminato
  }
}
