import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

class OrderRequests {
  final String baseUrl = 'http://10.0.2.2:3000';

  // Recupera tutti gli ordini per l'utente autenticato
  Future<List<Order>> fetchOrders(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((order) => Order.fromJson(order)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // Recupera un ordine specifico tramite ID
  Future<Order> fetchOrderById(String token, int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Order.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load order');
    }
  }

  // Crea un nuovo ordine
  Future<http.Response> createOrder(String token, Map<String, dynamic> orderData) {
    return http.post(
      Uri.parse('$baseUrl/api/orders/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(orderData),
    );
  }

  // Aggiorna lo stato di un ordine
  Future<http.Response> updateOrderStatus(String token, int id, String stato) {
    return http.put(
      Uri.parse('$baseUrl/api/orders/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'stato': stato}),
    );
  }

  // Cancella un ordine
  Future<http.Response> deleteOrder(String token, int id) {
    return http.delete(
      Uri.parse('$baseUrl/api/orders/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // Aggiorna lo stato dell'ordine a "pagato"
  Future<http.Response> markAsPaid(String token, int id) {
    return http.put(
      Uri.parse('$baseUrl/api/orders/$id/pay'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).then((response) {
      if (response.statusCode != 200) {
        print('Errore nel completare il pagamento: ${response.body}'); // Log in caso di errore
      }
      return response;
    });
  }

  // Modifica di un ordine
  Future<http.Response> updateOrder(String token, int id, Map<String, dynamic> updateData) {
    return http.put (
      Uri.parse('$baseUrl/api/orders/update-order/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).then((response) {
      if (response.statusCode != 200) {
        print('Errore nell\'aggiornare l\'ordine: ${response.body}');
      }
      return response;
    });
  }

}
