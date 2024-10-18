import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class CategoryRequests {
  // Definisci l'URL di base per l'API
  final String baseUrl = 'http://10.0.2.2:3000';

  // Funzione per recuperare tutte le categorie dall'API
  Future<List<Category>> getAllCategories() async {
    // Esegui una richiesta HTTP GET all'endpoint delle categorie
    final response = await http.get(
      Uri.parse('$baseUrl/api/categories'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // Verifica se la risposta HTTP ha avuto successo
    if (response.statusCode == 200) {
      // Decodifica la risposta JSON
      List jsonResponse = json.decode(response.body);

      // Mappa il JSON in una lista di oggetti Category
      return jsonResponse.map((category) => Category.fromJson(category)).toList();
    } else {
      // Lancia un'eccezione in caso di errore
      throw Exception('Errore nel recuperare le categorie');
    }
  }
}
