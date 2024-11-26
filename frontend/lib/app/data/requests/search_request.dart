import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auction_model.dart';

class SearchRequests {
  // final String baseUrl = 'http://10.0.2.2:3000'; // ENDPOINT per il localhost
  final String baseUrl = 'http://51.20.181.177:3000'; // ENDPOINT per AWS

  // Funzione per eseguire la ricerca con query e/o categoryId
  Future<List<Auction>> searchAuctions(String token, {String? query, String? categoryId}) async {
    final Map<String, String> queryParams = {};

    // Aggiungiamo i parametri di ricerca solo se esistono
    if (query != null && query.isNotEmpty) {
      queryParams['query'] = query;
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }

    final uri = Uri.parse('$baseUrl/api/search').replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((auction) => Auction.fromJson(auction)).toList();
    } else {
      throw Exception('Errore nel caricamento dei risultati di ricerca');
    }
  }
}
