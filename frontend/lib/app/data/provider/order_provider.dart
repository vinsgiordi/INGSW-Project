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

  // Cancella un ordine
  Future<void> deleteOrder(String token, int id) async {
    try {
      await OrderRequests().deleteOrder(token, id);
      fetchOrders(token); // Aggiorna la lista dopo la cancellazione
    } catch (e) {
      print('Error deleting order: $e');
    }
  }
}
