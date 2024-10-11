import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/provider/seller_provider.dart';
import 'product_detail.dart';  // Import della pagina di dettaglio prodotto

class SellerProfilePage extends StatefulWidget {
  final int venditoreId;

  const SellerProfilePage({required this.venditoreId, Key? key}) : super(key: key);

  @override
  _SellerProfilePageState createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  @override
  void initState() {
    super.initState();
    print("Venditore ID: ${widget.venditoreId}");

    // Recupera i dettagli del venditore non appena la pagina viene inizializzata
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Recupera il token da SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');

      if (token != null) {
        // Chiama fetchSellerDetails passando il token e l'ID del venditore
        await Provider.of<SellerProvider>(context, listen: false)
            .fetchSellerDetails(token, widget.venditoreId);
      } else {
        print("Token non disponibile");  // Gestisci il caso in cui il token non è disponibile
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Recupera i dati del venditore dal provider
    final sellerProvider = Provider.of<SellerProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profilo Venditore'),
      ),
      body: sellerProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: sellerProvider.seller?.avatar != null
                      ? NetworkImage(sellerProvider.seller!.avatar!)
                      : const AssetImage('images/user_avatar.png') as ImageProvider,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                '${sellerProvider.seller?.nome ?? 'Nome'} ${sellerProvider.seller?.cognome ?? 'Cognome'}',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                sellerProvider.seller?.shortBio ?? 'Descrizione non disponibile',
                style: const TextStyle(
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
              sellerProvider.products.isEmpty
                  ? const Text('Nessun prodotto in vendita')
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sellerProvider.products.length,
                itemBuilder: (context, index) {
                  final product = sellerProvider.products[index];
                  return ListTile(
                    leading: product.immaginePrincipale != null
                        ? Image.network(
                      product.immaginePrincipale!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'images/orologio-prova.jpg', // Usare il placeholder
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.nome),
                    subtitle: Text(
                      product.descrizione,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis, // Troncamento se il testo è troppo lungo
                    ),
                    trailing: Text(
                      '€${product.prezzoIniziale.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
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
