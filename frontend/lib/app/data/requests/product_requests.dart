import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductRequests {
  // final String baseUrl = 'http://10.0.2.2:3000'; // ENDPOINT per il localhost
  static const String baseUrl = 'http://51.20.181.177:3000'; // ENDPOINT per AWS

  // Ottieni i dettagli del prodotto e dell'asta
  static Future<Map<String, dynamic>> getProductDetails(int productId) async {
    final url = Uri.parse('$baseUrl/api/products/$productId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load product details');
    }
  }

  // Fai un'offerta
  static Future<void> makeOffer(double offerAmount, int auctionId) async {
    final url = Uri.parse('$baseUrl/api/bids/create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'auction_id': auctionId,
        'importo': offerAmount,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to make offer');
    }
  }
}
