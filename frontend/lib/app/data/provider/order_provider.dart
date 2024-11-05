import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../requests/order_request.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  // Recupera tutti gli ordini dell'utente autenticato
  void fetchOrders(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await OrderRequests().fetchOrders(token);
    } catch (e) {
      print('Error fetching orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Recupera un singolo ordine tramite ID
  Future<Order?> fetchOrderById(String token, int id) async {
    try {
      return await OrderRequests().fetchOrderById(token, id);
    } catch (e) {
      print('Error fetching order by ID: $e');
      return null;
    }
  }

  // Crea un nuovo ordine
  Future<void> createOrder(String token, Map<String, dynamic> orderData) async {
    try {
      await OrderRequests().createOrder(token, orderData);
      fetchOrders(token); // Aggiorna la lista dopo la creazione
    } catch (e) {
      print('Error creating order: $e');
    }
  }

  // Aggiorna lo stato di un ordine
  Future<void> updateOrderStatus(String token, int id, String stato) async {
    try {
      await OrderRequests().updateOrderStatus(token, id, stato);
      fetchOrders(token); // Aggiorna la lista dopo l'aggiornamento
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  // Imposta lo stato di un ordine come "pagato"
  Future<bool> markOrderAsPaid(String token, int id) async {
    try {
      final response = await OrderRequests().markAsPaid(token, id);
      print('Response status code: ${response.statusCode}'); // Log dello status code
      if (response.statusCode == 200) {
        fetchOrders(token); // Aggiorna la lista ordini
        return true; // Ritorna "true" in caso di successo
      } else {
        print('Error in response: ${response.body}'); // Log in caso di errore
      }
    } catch (e) {
      print('Errore nel segnare l\'ordine come pagato: $e');
    }
    return false; // Ritorna "false" in caso di errore
  }

  // Cancella un ordine
  Future<void> deleteOrder(String token, int id) async {
    try {
      await OrderRequests().deleteOrder(token, id);
      fetchOrders(token); // Aggiorna la lista dopo la cancellazione
    } catch (e) {
      print('Error deleting order: $e');
    }
  }

  // Modifica un ordine
  Future<bool> updateOrder(String token, int id, Map<String, dynamic> updateData) async {
    try {
      final response = await OrderRequests().updateOrder(token, id, updateData);
      if (response.statusCode == 200) {
        fetchOrders(token); // Aggiorna la lista ordini dopo la modifica
        return true; // Ritorna true in caso di successo
      } else {
        print('Error updating order: ${response.body}');
        return false; // Ritorna false in caso di errore
      }
    } catch (e) {
      print('Error updating order: $e');
      return false; // Ritorna false in caso di eccezione
    }
  }
}
