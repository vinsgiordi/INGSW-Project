import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../requests/payment_request.dart';

class PaymentProvider with ChangeNotifier {
  List<Payment> _payments = [];
  bool _isLoading = false;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;

  final PaymentRequests _paymentRequests = PaymentRequests();

  // Metodo per recuperare i pagamenti
  Future<void> fetchPayments(String token) async {
    _isLoading = true;
    notifyListeners(); // Notifica che è iniziato il caricamento

    try {
      _payments = await _paymentRequests.getPayments(token);
    } catch (e) {
      print('Errore nel recupero dei pagamenti: $e');
    }

    _isLoading = false;
    notifyListeners(); // Notifica che il caricamento è terminato
  }

  // Metodo per aggiungere un pagamento e aggiornare la lista dal server
  Future<void> addPayment(String token, Payment payment) async {
    try {
      final newPayment = await _paymentRequests.createPayment(token, payment);
      _payments.add(newPayment);

      // Subito dopo aver aggiunto il pagamento, aggiorna l'intera lista dei pagamenti dal server
      await fetchPayments(token);
      notifyListeners();
    } catch (e) {
      print('Errore nell\'aggiunta del pagamento: $e');
    }
  }


  // Metodo per eliminare un pagamento
  Future<void> deletePayment(String token, int paymentId) async {
    try {
      await _paymentRequests.deletePayment(token, paymentId);
      _payments.removeWhere((payment) => payment.id == paymentId);
      notifyListeners(); // Notifica l'aggiornamento
    } catch (e) {
      print('Errore nella cancellazione del pagamento: $e');
    }
  }
}
