import 'package:flutter/material.dart';

class SoldPage extends StatelessWidget {
  final List<String> soldItems = ['Prodotto 1', 'Prodotto 2']; // Simulazione dei dati venduti

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venduti'),
      ),
      body: soldItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/donna_che_ordina.jpg'), // Aggiungi la tua immagine
            const SizedBox(height: 20),
            const Text('Ancora nessun prodotto venduto.'),
          ],
        ),
      )
          : ListView.builder(
        itemCount: soldItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(soldItems[index]),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          );
        },
      ),
    );
  }
}