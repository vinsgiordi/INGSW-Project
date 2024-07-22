import 'package:flutter/material.dart';

class AddressesPage extends StatefulWidget {
  @override
  _AddressesPageState createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  bool _isBillingSameAsShipping = true;
  final TextEditingController _shippingAddressController = TextEditingController(text: 'NAPOLI 168:A\n80053 CASTELLAMMARE DI STABIA\nITALIA');
  final TextEditingController _billingAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_isBillingSameAsShipping) {
      _billingAddressController.text = _shippingAddressController.text;
    }
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
          ],
        ),
      ),
    );
  }
}