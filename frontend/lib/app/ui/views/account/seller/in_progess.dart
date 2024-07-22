import 'package:flutter/material.dart';

class InProgressPage extends StatelessWidget {
  final List<String> inProgressItems = ['Prodotto 1', 'Prodotto 2'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In Elaborazione'),
      ),
      body: inProgressItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/donna_che_ordina.jpg'), // Aggiungi la tua immagine
            const SizedBox(height: 20),
            const Text('Ancora nessun prodotto in elaborazione.'),
          ],
        ),
      )
          : ListView.builder(
        itemCount: inProgressItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(inProgressItems[index]),
            trailing: const Icon(Icons.hourglass_empty),
          );
        },
      ),
    );
  }
}