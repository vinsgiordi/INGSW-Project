import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bid_model.dart';
import '../requests/bid_request.dart';

class BidProvider extends ChangeNotifier {
  List<Bid> _bids = [];
  bool _isLoading = false;

  List<Bid> get bids => _bids;
  bool get isLoading => _isLoading;

  // Crea una nuova offerta
  Future<void> createBid(String token, Map<String, dynamic> bidData) async {
    try {
      await BidRequests().createBid(token, bidData);
      await fetchBidsByProduct(token, bidData['prodotto_id']);
    } catch (e) {
      print('Error creating bid: $e');
    }
  }

  // Recupera tutte le offerte per un prodotto
  Future<void> fetchBidsByProduct(String token, int prodottoId) async {
    _isLoading = true;

    // Differisci la notifica di aggiornamento dopo il build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _bids = await BidRequests().getBidsByProduct(token, prodottoId);
    } catch (e) {
      print('Error fetching bids: $e');
    }

    _isLoading = false;

    // Differisci la notifica di aggiornamento dopo il build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Recupera tutte le offerte dell'utente
  Future<void> fetchBidsByUser(String token) async {
    _isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _bids = await BidRequests().getBidsByUser(token);
    } catch (e) {
      print('Error fetching user bids: $e');
    }

    _isLoading = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Elimina un'offerta
  Future<void> deleteBid(String token, int id) async {
    try {
      await BidRequests().deleteBid(token, id);
      _bids.removeWhere((bid) => bid.id == id);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('Error deleting bid: $e');
    }
  }
}
