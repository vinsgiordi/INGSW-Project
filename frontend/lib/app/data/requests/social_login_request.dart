import 'dart:convert';
import 'package:http/http.dart' as http;

class SocialLoginRequest {
  // final String baseUrl = 'http://10.0.2.2:3000'; // ENDPOINT per il localhost
  final String baseUrl = 'http://51.20.181.177:3000'; // ENDPOINT per AWS

  // Funzione per login tramite un provider social (Google, Facebook, GitHub, LinkedIn)
  Future<String> loginWithProvider(String provider) async {
    final url = '$baseUrl/auth/$provider'; // Costruiamo l'URL in base al provider selezionato

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['token'] != null) {
        return jsonResponse['token']; // Restituiamo il token JWT
      } else {
        throw Exception('Login fallito: Nessun token ricevuto.');
      }
    } else {
      throw Exception('Login fallito: ${response.statusCode}');
    }
  }
}
