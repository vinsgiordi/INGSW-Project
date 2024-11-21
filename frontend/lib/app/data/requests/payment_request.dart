import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';

class PaymentRequests {
  final String baseUrl = 'http://10.0.2.2:3000';

  // Crea un nuovo metodo di pagamento
  Future<Payment> createPayment(String token, Payment payment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/payments/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payment.toJson()),  // Convertiamo l'oggetto Payment in JSON
    );

    if (response.statusCode == 201) {
      return Payment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create payment');
    }
  }

  // Recupera tutti i metodi di pagamento dell'utente
  Future<List<Payment>> getPayments(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/payments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((payment) => Payment.fromJson(payment)).toList();
    } else {
      throw Exception('Failed to load payments');
    }
  }

  // Elimina un metodo di pagamento
  Future<void> deletePayment(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/payments/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete payment');
    }
  }
}
