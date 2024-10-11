import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auction_model.dart';

class AuctionRequests {
  final String baseUrl = 'http://10.0.2.2:3000'; // Sostituisci con l'URL del tuo server

  // Crea una nuova asta
  Future<Auction> createAuction(String token, Map<String, dynamic> auctionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auctions/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(auctionData),
    );

    if (response.statusCode == 201) {
      return Auction.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create auction');
    }
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
      Uri.parse('$baseUrl/api/auctions/by-type'), // L'endpoint che restituisce le aste per tipo
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
}
