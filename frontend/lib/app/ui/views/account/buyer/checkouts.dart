import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../services/storage_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/provider/order_provider.dart';
import '../../../../data/provider/payment_provider.dart';
import '../settings/payment.dart';

class CheckoutPage extends StatefulWidget {
  final Order order;

  const CheckoutPage({Key? key, required this.order}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressController = TextEditingController();
  final _storageService = StorageService();
  static const double shippingCost = 10.0;

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.order.indirizzoSpedizione;
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final token = await _storageService.getAccessToken();
    if (token != null) {
      // Aggiorna la lista di pagamenti ogni volta che entriamo nel checkout
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      await paymentProvider.fetchPayments(token);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double totalAmount = widget.order.importoTotale + shippingCost;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Indirizzo di Spedizione"),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Inserisci il tuo indirizzo di spedizione',
              ),
            ),
            const SizedBox(height: 20),
            Text("Costo Spedizione: €${shippingCost.toStringAsFixed(2)}"),
            const SizedBox(height: 10),
            Text(
              "Totale da Pagare: €${totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Effettua Pagamento"),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() async {
    final token = await _storageService.getAccessToken();
    if (token != null) {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

      // Aggiorna i pagamenti per assicurarti di avere l'ultimo metodo disponibile
      await paymentProvider.fetchPayments(token);
      final List<Payment> payments = paymentProvider.payments;

      if (payments.isEmpty) {
        _showAddCardDialog(context);
        return;
      }

      if (widget.order.id != null) {
        bool success = await Provider.of<OrderProvider>(context, listen: false)
            .markOrderAsPaid(token, widget.order.id!);

        if (success) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore nel completare il pagamento')),
          );
        }
      } else {
        print("Errore: l'ID dell'ordine è null e il pagamento non può essere completato.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore: ID ordine non valido')),
        );
      }
    }
  }


  void _showAddCardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nessuna carta disponibile'),
          content: const Text('Per procedere con il pagamento, aggiungi un metodo di pagamento.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aggiungi Carta'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentsPage()),
                ).then((_) {
                  // Dopo aver aggiunto una carta, ricarica la lista dei pagamenti
                  _loadPayments();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
