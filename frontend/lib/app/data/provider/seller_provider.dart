import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../requests/seller_request.dart';

class SellerProvider with ChangeNotifier {
  User? _seller;
  List<Product> _products = [];
  bool _isLoading = false;

  User? get seller => _seller;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // Metodo per recuperare i dettagli del venditore
  Future<void> fetchSellerDetails(String token, int sellerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await SellerRequest().getSellerDetails(token, sellerId);

      // Mappare i dati del venditore
      _seller = User.fromJson(response['venditore']);

      // Mappare i prodotti all'interno del venditore
      if (response['venditore']['Products'] != null) {
        _products = (response['venditore']['Products'] as List)
            .map((productJson) => Product.fromJson(productJson))
            .toList();
      } else {
        _products = [];
      }
    } catch (e) {
      print('Errore durante il recupero dei dettagli del venditore: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
