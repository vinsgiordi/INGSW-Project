import 'package:flutter/material.dart';

class UnsoldPage extends StatelessWidget {
  final List<String> unsoldItems = ['Prodotto 1', 'Prodotto 2']; // Simulazione dei dati non venduti

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Non venduti'),
      ),
      body: unsoldItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/donna_che_ordina.jpg',
              height: 190,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text('Ancora nessun prodotto non venduto.'),
          ],
        ),
      )
          : ListView.builder(
        itemCount: unsoldItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(unsoldItems[index]),
            trailing: const Icon(Icons.close, color: Colors.red),
          );
        },
      ),
    );
  }
}