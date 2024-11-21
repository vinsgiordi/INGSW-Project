import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/provider/user_provider.dart';

class AddressesPage extends StatefulWidget {
  @override
  _AddressesPageState createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  bool _isBillingSameAsShipping = true;
  final TextEditingController _shippingAddressController = TextEditingController();
  final TextEditingController _billingAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    if (token == null) {
      // Se il token è null, mostra un messaggio o reindirizza l'utente al login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token non disponibile, effettua il login.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return; // Fermiamo l'esecuzione se non c'è il token
    }

    // Se il token è valido, carica i dati dell'utente
    await userProvider.fetchUserData(token);
    setState(() {
      _shippingAddressController.text = userProvider.user?.indirizzoDiSpedizione ?? '';
      _billingAddressController.text = userProvider.user?.indirizzoDiFatturazione ?? '';
      _isBillingSameAsShipping = _shippingAddressController.text == _billingAddressController.text;
    });
  }


  void _saveAddresses() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    final updatedData = {
      'indirizzo_di_spedizione': _shippingAddressController.text,
      'indirizzo_di_fatturazione': _isBillingSameAsShipping
          ? _shippingAddressController.text
          : _billingAddressController.text,
    };

    await userProvider.updateUser(token!, updatedData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Indirizzi aggiornati con successo!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indirizzi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'INDIRIZZO DI SPEDIZIONE',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _shippingAddressController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isBillingSameAsShipping,
                  onChanged: (value) {
                    setState(() {
                      _isBillingSameAsShipping = value!;
                      if (_isBillingSameAsShipping) {
                        _billingAddressController.text = _shippingAddressController.text;
                      } else {
                        _billingAddressController.clear();
                      }
                    });
                  },
                ),
                const Text(
                  'Uguale all\'indirizzo di spedizione',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'INDIRIZZO DI FATTURAZIONE',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _billingAddressController,
              maxLines: 3,
              enabled: !_isBillingSameAsShipping,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _saveAddresses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Salva Indirizzi',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
