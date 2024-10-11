import 'package:flutter/material.dart';
import '../models/auction_model.dart';
import '../models/product_model.dart';
import '../requests/product_requests.dart';  // API Request per il prodotto

class ProductProvider with ChangeNotifier {
  Product? product;
  Auction? auction;

  Future<void> fetchProductDetails(int productId) async {
    try {
      final response = await ProductRequests.getProductDetails(productId);
      product = response['product'];
      auction = response['auction'];
      notifyListeners();
    } catch (error) {
      print('Error fetching product details: $error');
    }
  }

  Future<void> makeOffer(double offerAmount, int auctionId) async {
    try {
      await ProductRequests.makeOffer(offerAmount, auctionId);
      // Se l'offerta è fatta con successo, puoi aggiornare i dettagli del prodotto
      fetchProductDetails(product!.id);
    } catch (error) {
      print('Error making offer: $error');
    }
  }
}
