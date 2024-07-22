import 'package:flutter/material.dart';

class SellerProfilePage extends StatelessWidget {
  const SellerProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profilo Venditore'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('images/user_avatar.png'),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Nome Venditore',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Descrizione del venditore. Questo è un esempio di descrizione del venditore.',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Prodotti in vendita',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              // Qui puoi aggiungere una lista di prodotti in vendita del venditore
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 3, // Sostituisci con il numero di prodotti in vendita
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.asset('images/orologio-prova.jpg'),
                    title: Text('Prodotto $index'),
                    subtitle: Text('Descrizione del prodotto $index'),
                    trailing: Text('€${(index + 1) * 100}'),
                    onTap: () {
                      // Naviga alla pagina del dettaglio prodotto
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}