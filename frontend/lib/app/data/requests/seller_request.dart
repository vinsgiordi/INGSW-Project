import 'dart:convert';
import 'package:http/http.dart' as http;

class SellerRequest {
  final String baseUrl = 'http://10.0.2.2:3000';

  // Recupera i dettagli del venditore per ID
  Future<Map<String, dynamic>> getSellerDetails(String token, int sellerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/sellers/$sellerId'),
      headers: {
        'Authorization': 'Bearer $token',  // Aggiungiamo il token di autenticazione
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);  // Decodifica la risposta JSON
    } else {
      throw Exception('Errore durante il recupero dei dettagli del venditore');
    }
  }
}
