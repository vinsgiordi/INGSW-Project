import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../services/storage_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/provider/order_provider.dart';
import '../../../../data/provider/payment_provider.dart';
import '../../../../data/provider/user_provider.dart';
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
    _loadUserAddress();
    _loadPayments();
  }

  Future<void> _loadUserAddress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    if (token != null) {
      await userProvider.fetchUserData(token);

      if (userProvider.user != null) {
        _addressController.text = userProvider.user!.indirizzoDiSpedizione ?? '';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token non disponibile, effettua il login.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _loadPayments() async {
    final token = await _storageService.getAccessToken();
    if (token != null) {
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
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Imposta il colore del bordo a nero
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Colore bordo attivo
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0), // Colore bordo in focus
                ),
                hintText: 'Inserisci il tuo indirizzo di spedizione',
              ),
              cursorColor: Colors.black, // Colore cursore nero
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

  Future<void> _saveShippingAddress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    if (token != null) {
      final updatedData = {
        'indirizzo_di_spedizione': _addressController.text,
      };

      await userProvider.updateUser(token, updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indirizzo di spedizione aggiornato con successo!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore: Token non disponibile')),
      );
    }
  }

  void _processPayment() async {
    // Verifica se l'indirizzo è vuoto
    bool isAddressEmpty = _addressController.text.isEmpty;

    // Salva l'indirizzo di spedizione solo se è vuoto
    if (isAddressEmpty) {
      await _saveShippingAddress();
    }

    final token = await _storageService.getAccessToken();
    if (token != null) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      // Aggiorna l'indirizzo di spedizione nell'ordine
      bool addressUpdated = await orderProvider.updateOrder(
        token,
        widget.order.id!,
        {'indirizzo_spedizione': _addressController.text},
      );

      if (!addressUpdated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Errore nell'aggiornamento dell'indirizzo nell'ordine")),
        );
        return;
      }

      // Procedura di pagamento
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      await paymentProvider.fetchPayments(token);
      final List<Payment> payments = paymentProvider.payments;

      if (payments.isEmpty) {
        _showAddCardDialog(context);
        return;
      }

      if (widget.order.id != null) {
        bool success = await orderProvider.markOrderAsPaid(token, widget.order.id!);

        if (success) {
          // Mostra un messaggio diverso in base alla presenza dell'indirizzo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isAddressEmpty
                ? 'Indirizzo di spedizione aggiornato con successo!'
                : 'Ordine pagato con successo')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore nel completare il pagamento')),
          );
        }
      } else {
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
