import 'package:flutter/material.dart';
import '../models/user_model.dart';  // Importa il model dell'utente
import '../models/product_model.dart';  // Se hai un modello per i prodotti
import '../requests/seller_request.dart';  // Richieste HTTP per il venditore

class SellerProvider with ChangeNotifier {
  User? _seller;  // Usa il model User per il venditore
  List<Product> _products = [];  // Lista di prodotti
  bool _isLoading = false;

  User? get seller => _seller;  // Getter per il venditore
  List<Product> get products => _products;  // Getter per i prodotti
  bool get isLoading => _isLoading;  // Stato di caricamento

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
