import 'package:flutter/material.dart';
import '../models/auction_model.dart';
import '../models/user_model.dart';
import '../requests/auction_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuctionProvider with ChangeNotifier {
  List<Auction> _auctions = [];
  List<Auction> _activeAuctions = [];
  List<Auction> _endingSoonAuctions = [];
  List<Auction> _auctionType = [];
  List<Auction> _carouselAuctions = [];
  List<Auction> _unsoldAuctions = [];
  List<Auction> _activeUserAuctions = [];
  String? _accessToken;
  User? _user;
  bool _isUserSeller = false;
  bool _isLoading = false;

  List<Auction> get auctions => _auctions;
  List<Auction> get activeAuctions => _activeAuctions;
  List<Auction> get endingSoonAuctions => _endingSoonAuctions;
  List<Auction> get auctionType => _auctionType;
  List<Auction> get carouselAuctions => _carouselAuctions;
  List<Auction> get unsoldAuctions => _unsoldAuctions;
  List<Auction> get activeUserAuctions => _activeUserAuctions;
  User? get user => _user;
  bool get IsUserSeller => _isUserSeller;
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
      print('Dati dell\'asta ricevuti: ${auction
          .toJson()}'); // Verifica la risposta completa
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
    } catch (e) {
      print('Error loading auctions by type: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Crea una nuova asta
  Future<void> createAuction(Map<String, dynamic> auctionData, String? immaginePrincipale) async {
    try {
      // Verifica che il token non sia vuoto
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        throw Exception('Token mancante o non valido');
      }

      DateTime now = DateTime.now();

      // Aggiungi la data di scadenza se non è stata fornita
      if (!auctionData.containsKey('data_scadenza')) {
        auctionData['data_scadenza'] = now.add(Duration(hours: 1)).toIso8601String();  // 1 ora da adesso
      } else {
        DateTime parsedDate = DateTime.parse(auctionData['data_scadenza']);
        auctionData['data_scadenza'] = parsedDate.toIso8601String();
      }

      // Aggiungi l'immagine se presente
      Map<String, dynamic> newAuctionData = {
        ...auctionData,
        if (immaginePrincipale != null) 'immagine_principale': immaginePrincipale,
      };

      // Passa il token corretto alla richiesta
      final response = await AuctionRequests().createAuction(token, newAuctionData);

      if (response.statusCode != 201) {
        throw Exception('Errore nella creazione dell\'asta: ${response.body}');
      }

      await fetchAllAuctions(token);
    } catch (e) {
      print('Error creating auction: $e');
    }
  }

  // Recupera tutte le aste vendute dall'utente
  Future<void> fetchSoldAuctions(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _auctions = await AuctionRequests().getSoldAuctions(token); // Usa la nuova API
    } catch (e) {
      print('Errore nel caricamento delle aste vendute: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Recupera tutte le aste non vendute
  Future<void> fetchUnsoldAuctions(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _unsoldAuctions = await AuctionRequests().getUnsoldAuctions(token);
    } catch (e) {
      print('Errore nel caricamento delle aste non vendute: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Accetta un'offerta per un'asta silenziosa
  Future<void> acceptBidForSilentAuction(String token, int auctionId, int bidId) async {
    try {
      await AuctionRequests().acceptBidForSilentAuction(token, auctionId, bidId);
      // Aggiorna le aste dopo l'operazione
      await fetchAllAuctions(token);
    } catch (e) {
      print('Errore nell\'accettazione dell\'offerta: $e');
    }
  }

  // Rifiuta tutte le offerte per un'asta silenziosa
  Future<void> rejectAllBidsForSilentAuction(String token, int auctionId) async {
    try {
      await AuctionRequests().rejectAllBidsForSilentAuction(token, auctionId);
      // Aggiorna le aste dopo l'operazione
      await fetchAllAuctions(token);
    } catch (e) {
      print('Errore nel rifiuto delle offerte: $e');
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
  Future<bool> deleteAuction(String token, int auctionId) async {
    try {
      // Effettua la chiamata API per eliminare l'asta
      await AuctionRequests().deleteAuction(token, auctionId);
      // Rimuove l'asta dalla lista locale
      _activeUserAuctions.removeWhere((auction) => auction.id == auctionId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Errore durante l\'eliminazione dell\'asta: $e');
      return false;
    }
  }

  // Funzione per verificare se l'utente loggato è il venditore dell'asta
  Future<bool> verifyUserIsSeller(String token, int auctionId) async {
    try {
      // Esegui la richiesta per verificare se l'utente è il venditore
      final isSeller = await AuctionRequests().checkIfUserIsSeller(auctionId, token);
      return isSeller; // Ritorna il risultato
    } catch (e) {
      print('Errore nella verifica se l\'utente è il venditore: $e');
      return false; // In caso di errore, ritorna false
    }
  }

  // Recupera tutte le aste attive di un utente loggato
  Future<void> fetchUserActiveAuctions(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final activeAuctions = await AuctionRequests().getUserActiveAuctions(token);
      _activeUserAuctions = activeAuctions; // Aggiorna _activeUserAuctions con i risultati
    } catch (e) {
      print('Errore nel caricamento delle aste attive dell\'utente: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
