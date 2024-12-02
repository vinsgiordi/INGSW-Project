import 'dart:convert';
import 'package:http/http.dart' as http;

class SellerRequest {
  // final String baseUrl = 'http://10.0.2.2:3000'; // ENDPOINT per il localhost
  final String baseUrl = 'http://51.20.181.177:3000'; // ENDPOINT per AWS

  // Recupera i dettagli del venditore per ID
  Future<Map<String, dynamic>> getSellerDetails(String token, int sellerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/sellers/$sellerId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Errore durante il recupero dei dettagli del venditore');
    }
  }
}
