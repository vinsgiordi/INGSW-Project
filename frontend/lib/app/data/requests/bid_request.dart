import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bid_model.dart';

class BidRequests {
  // final String baseUrl = 'http://10.0.2.2:3000'; // ENDPOINT per il localhost
  final String baseUrl = 'http://51.20.181.177:3000'; // ENDPOINT per AWS

  // Crea una nuova offerta
  Future<Bid> createBid(String token, Map<String, dynamic> bidData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/bids/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(bidData),
    );

    if (response.statusCode == 201) {
      return Bid.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create bid');
    }
  }

  // Recupera tutte le offerte per un prodotto
  Future<List<Bid>> getBidsByProduct(String token, int prodottoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bids/prodotto/$prodottoId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((bid) => Bid.fromJson(bid)).toList();
    } else {
      print('Failed to load bids, status code: ${response.statusCode}, body: ${response.body}');
      throw Exception('Failed to load bids');    }
  }

  // Recupera tutte le offerte dell'utente
  Future<List<Bid>> getBidsByUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bids/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((bid) => Bid.fromJson(bid)).toList();
    } else {
      throw Exception('Failed to load user bids');
    }
  }

  // Elimina un'offerta
  Future<void> deleteBid(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/bids/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete bid');
    }
  }
}

