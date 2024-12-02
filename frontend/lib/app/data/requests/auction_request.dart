import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auction_model.dart';

class AuctionRequests {
  // final String baseUrl = 'http://10.0.2.2:3000'; // ENDPOINT per il localhost
  final String baseUrl = 'http://51.20.181.177:3000'; // ENDPOINT per AWS

  // Crea una nuova asta
  Future<http.Response> createAuction(String token, Map<String, dynamic> auctionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auctions/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(auctionData),
    );

    if (response.statusCode != 201) {
      print('Errore durante la creazione dell\'asta: ${response.statusCode}, ${response.body}');
    }

    return response;
  }

  // Recupera tutte le aste
  Future<List<Auction>> getAllAuctions(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auctions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((auction) => Auction.fromJson(auction)).toList();
    } else {
      throw Exception('Failed to load auctions');
    }
  }

  // Recupera un'asta per ID
  Future<Auction> getAuctionById(String token, int auctionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auctions/$auctionId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Auction.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load auction');
    }
  }

  // Recupera un'asta filtrata per categoria
  Future<List<Auction>> getAuctionsByCategory(String token, String categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auctions/category/$categoryId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((auction) => Auction.fromJson(auction)).toList();
    } else {
      throw Exception('Failed to load auctions for category: $categoryId');
    }
  }

  // Recupera un'asta attiva
  Future<List<Auction>> getActiveAuctions(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auctions/active'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((auction) => Auction.fromJson(auction)).toList();
    } else {
      throw Exception('Failed to load active auctions');
    }
  }

  // Recupera le aste che terminano a breve
  Future<List<Auction>> getAuctionsEndingSoon(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auctions/ending-soon'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((auction) => Auction.fromJson(auction)).toList();
    } else {
      throw Exception('Failed to load auctions ending soon');
    }
  }

  // Recupera tutte le aste per tipo
  Future<List<Auction>> getAuctionsByType(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auctions/by-type'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      // Mappiamo la risposta in oggetti Auction
      return data.map((auction) => Auction.fromJson(auction)).toList();
    } else {
      throw Exception('Failed to load auctions by type');
    }
  }

  // Recupera tutte le aste vendute
  Future<List<Auction>> getSoldAuctions(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auctions/completed'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((auction) => Auction.fromJson(auction)).toList();
    } else {
      throw Exception('Failed to load sold auctions');
    }
  }

  // Recupera tutte le aste non vendute
  Future<List<Auction>> getUnsoldAuctions(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auctions/unsold'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((auction) => Auction.fromJson(auction)).toList();
    } else {
      throw Exception('Errore nel caricamento delle aste non vendute');
    }
  }

  // Accetta un'offerta per un'asta silenziosa
  Future<void> acceptBidForSilentAuction(String token, int auctionId, int bidId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auctions/silent-auction/$auctionId/accept-bid/$bidId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Errore nell\'accettazione dell\'offerta');
    }
  }

// Rifiuta tutte le offerte per un'asta silenziosa
  Future<void> rejectAllBidsForSilentAuction(String token, int auctionId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auctions/silent-auction/$auctionId/reject-all-bids'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Errore nel rifiuto delle offerte');
    }
  }

  // Aggiorna un'asta
  Future<void> updateAuction(String token, int id, Map<String, dynamic> auctionData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/auctions/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(auctionData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update auction');
    }
  }

  // Cancella un'asta
  Future<void> deleteAuction(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/auctions/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete auction');
    }
  }

  // Verifichiamo se l'utente loggato è il venditore dell'asta
  Future<bool> checkIfUserIsSeller(int auctionId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auctions/$auctionId/isUserSeller'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['isSeller'] as bool;
    } else {
      print("Errore nel controllo del venditore: ${response.statusCode}, ${response.body}");
      throw Exception('Errore nel controllo del venditore');
    }
  }

  // Recupera tutte le aste attive di un utente loggato
  Future<List<Auction>> getUserActiveAuctions(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auctions/user/active'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic> && data.containsKey('message')) {
        // Messaggio per utente senza aste attive
        print(data['message']);
        return [];
      } else {
        return (data as List).map((auction) => Auction.fromJson(auction)).toList();
      }
    } else {
      throw Exception('Errore nel caricamento delle aste attive dell\'utente');
    }
  }

}