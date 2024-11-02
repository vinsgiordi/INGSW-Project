import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/models/payment_model.dart';
import '../../../../data/provider/payment_provider.dart';

class PaymentsPage extends StatefulWidget {
  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final TextEditingController _numeroCartaController = TextEditingController();
  final TextEditingController _nomeIntestatarioController = TextEditingController();
  final TextEditingController _dataScadenzaController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchPayments();
  }

  // Recupera il token salvato in SharedPreferences e recupera i pagamenti
  Future<void> _loadTokenAndFetchPayments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('accessToken'); // Recupera il token dal login

    if (_token != null) {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      await paymentProvider.fetchPayments(_token!);
    } else {
      // Se il token non è presente, potresti voler reindirizzare l'utente al login o mostrare un errore
      print("Token non trovato");
    }
  }

  // Metodo per svuotare i campi del form
  void _clearFields() {
    _numeroCartaController.clear();
    _nomeIntestatarioController.clear();
    _dataScadenzaController.clear();
    _cvcController.clear();
  }

  // Metodo per mostrare il modale per aggiungere una carta
  void _showAddCardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearFields(); // Svuota i campi quando si chiude il modale
                        },
                        child: const Text('Annulla', style: TextStyle(color: Colors.blue)),
                      ),
                      const Text('Aggiungi una carta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () async {
                          await _addPayment();
                          Navigator.pop(context);
                        },
                        child: const Text('Fine', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nomeIntestatarioController,
                    label: 'Intestatario carta',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _numeroCartaController,
                    label: 'Numero carta',
                    icon: Icons.credit_card,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _dataScadenzaController,
                    label: 'MM/AAAA',
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _cvcController,
                    label: 'CVC',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Metodo per costruire un TextField con i colori personalizzati manualmente
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        labelStyle: const TextStyle(color: Colors.black),
      ),
    );
  }

  String _obfuscateCardNumber(String cardNumber) {
    if (cardNumber.length <= 4) return cardNumber;
    return '*' * (cardNumber.length - 4) + cardNumber.substring(cardNumber.length - 4);
  }

  // Metodo per aggiungere un nuovo metodo di pagamento
  Future<void> _addPayment() async {
    if (_token != null) {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

      // Formattare la data di scadenza per evitare errori
      final List<String> expiryParts = _dataScadenzaController.text.split('/');
      if (expiryParts.length != 2) {
        print("Errore nel formato della data di scadenza");
        return;
      }
      final int month = int.parse(expiryParts[0]);
      final int year = int.parse(expiryParts[1]) + 2000; // Assumendo che inserisca solo AA

      final Payment newPayment = Payment(
        id: 0,
        utenteId: 0,
        numeroCarta: _obfuscateCardNumber(_numeroCartaController.text),
        nomeIntestatario: _nomeIntestatarioController.text,
        dataScadenza: DateTime(year, month, 1),
      );

      await paymentProvider.addPayment(_token!, newPayment);
      await paymentProvider.fetchPayments(_token!); // Ricarica le carte salvate

      _clearFields();
    } else {
      print("Token non trovato");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamenti'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Aggiungi padding ai lati
        child: Consumer<PaymentProvider>(
          builder: (context, paymentProvider, child) {
            if (paymentProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (paymentProvider.payments.isEmpty) {
              return const Center(child: Text('Nessun metodo di pagamento disponibile'));
            }

            return ListView.builder(
              itemCount: paymentProvider.payments.length,
              itemBuilder: (context, index) {
                final payment = paymentProvider.payments[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.credit_card, color: Colors.blue), // Forza il colore dell'icona a blu
                    title: Text(payment.numeroCarta),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Intestatario: ${payment.nomeIntestatario}'),
                        Text('Scadenza: ${payment.dataScadenza.month}/${payment.dataScadenza.year}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        paymentProvider.deletePayment(_token!, payment.id);
                        _clearFields(); // Svuota i campi dopo la cancellazione
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCardModal(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
