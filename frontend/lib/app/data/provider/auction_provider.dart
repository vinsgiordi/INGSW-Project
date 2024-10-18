import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/auction_model.dart';
import '../requests/auction_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuctionProvider with ChangeNotifier {
  List<Auction> _auctions = [];
  List<Auction> _activeAuctions = [];
  List<Auction> _endingSoonAuctions = [];
  List<Auction> _auctionType = [];
  List<Auction> _carouselAuctions = [];
  bool _isLoading = false;

  List<Auction> get auctions => _auctions;
  List<Auction> get activeAuctions => _activeAuctions;
  List<Auction> get endingSoonAuctions => _endingSoonAuctions;
  List<Auction> get auctionType => _auctionType;
  List<Auction> get carouselAuctions => _carouselAuctions;
  bool get isLoading => _isLoading;

  // Recupera tutte le aste
  Future<void> fetchAllAuctions(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _auctions = await AuctionRequests().getAllAuctions(token);
    } catch (e) {
      print('Error fetching auctions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Recupera un'asta per ID
  Future<Auction?> fetchAuctionById(String token, int auctionId) async {
    try {
      final auction = await AuctionRequests().getAuctionById(token, auctionId);
      return auction;
    } catch (e) {
      print('Errore nel recupero dell\'asta: $e');
      return null; // Restituisci null in caso di errore
    }
  }

  // Recupera tutte le aste filtrate per categoria
  Future<void> fetchAuctionsByCategory(String token, String categoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _auctions = await AuctionRequests().getAuctionsByCategory(token, categoryId);
      print('Aste caricate per la categoria $categoryId: $_auctions');
    } catch (e) {
      print('Errore nel caricamento delle aste per categoria: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Funzione per pulire i risultati
  void clearAuctions() {
    _auctions = [];
    notifyListeners();
  }

  // Funzione per recuperare le aste filtrate da mostrare nel carosello
  Future<void> fetchCarouselAuctions(String token, List<String> categoryIds) async {
    _isLoading = true;
    _carouselAuctions.clear(); // Pulisci le aste precedenti
    notifyListeners();

    try {
      for (var categoryId in categoryIds) {
        List<Auction> auctionsForCategory = await AuctionRequests().getAuctionsByCategory(token, categoryId);
        _carouselAuctions.addAll(auctionsForCategory);
      }
      print('Aste caricate per il carosello: $_carouselAuctions');
    } catch (e) {
      print('Errore nel caricamento delle aste per il carosello: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Recupera tutte le aste attive
  Future<void> fetchActiveAuctions(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _activeAuctions = await AuctionRequests().getActiveAuctions(token);
      print("Auction data received: $_activeAuctions");
    } catch (e) {
      print('Error fetching active auctions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Recupera tutte le aste che terminano a breve
  Future<void> fetchAuctionsEndingSoon(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _endingSoonAuctions = await AuctionRequests().getAuctionsEndingSoon(token);
      print("Auction data for ending soon: $_endingSoonAuctions");
    } catch (e) {
      print('Error fetching auctions ending soon: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Recupera tutte le aste per tipo
  Future<void> fetchAuctionByType(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _auctionType = await AuctionRequests().getAuctionsByType(token);
      print("Auction data by type: $_auctionType");
    } catch (e) {
      print('Error loading auctions by type: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Crea una nuova asta
  Future<void> createAuction(String token, Map<String, dynamic> auctionData, String? immaginePrincipale) async {
    try {
      // Stampa la data corrente del device
      DateTime now = DateTime.now();
      print('Data corrente del device: $now');

      // Aggiungi la data di scadenza se non è stata fornita
      if (!auctionData.containsKey('data_scadenza')) {
        auctionData['data_scadenza'] = now.add(Duration(hours: 1)).toIso8601String();  // 1 ora da adesso
      } else {
        // Se la data è stata fornita, lasciala così com'è (senza conversione a UTC)
        DateTime parsedDate = DateTime.parse(auctionData['data_scadenza']);
        auctionData['data_scadenza'] = parsedDate.toIso8601String();
      }

      // Stampa la data di scadenza inviata al backend
      print('Data di scadenza inviata al backend: ${auctionData['data_scadenza']}');

      // Aggiungi un log per vedere i dati prima di inviarli
      print('Dati prima dell\'invio: $auctionData, immagine: $immaginePrincipale');

      // Controlla se l'immagine è null, altrimenti rimuovi il campo
      Map<String, dynamic> newAuctionData = {
        ...auctionData,
        if (immaginePrincipale != null) 'immagine_principale': immaginePrincipale,
      };

      print('Dati finali inviati al backend: $newAuctionData');

      // Effettua la richiesta di creazione dell'asta
      final response = await AuctionRequests().createAuction(token, newAuctionData);

      if (response.statusCode != 201) {
        print('Errore dal server: ${response.statusCode}, ${response.body}');
        throw Exception('Errore nella creazione dell\'asta: ${response.body}');
      }

      await fetchAllAuctions(token);
    } catch (e) {
      print('Error creating auction: $e');
    }
  }

  // Aggiorna un'asta
  Future<void> updateAuction(String token, int id, Map<String, dynamic> auctionData) async {
    try {
      await AuctionRequests().updateAuction(token, id, auctionData);
      fetchAllAuctions(token);
    } catch (e) {
      print('Error updating auction: $e');
    }
  }

  // Cancella un'asta
  Future<void> deleteAuction(String token, int id) async {
    try {
      await AuctionRequests().deleteAuction(token, id);
      fetchAllAuctions(token);
    } catch (e) {
      print('Error deleting auction: $e');
    }
  }
}
