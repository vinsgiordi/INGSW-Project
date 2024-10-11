import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/models/auction_model.dart';
import '../data/provider/auction_provider.dart';
import '../data/provider/favorites_provider.dart';
import '../data/provider/seller_provider.dart';
import '../data/provider/user_provider.dart';
import '../data/provider/bid_provider.dart';
import 'seller_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatefulWidget {
  final int auctionId; // L'ID dell'asta

  const ProductDetailPage({required this.auctionId, Key? key}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isFavorite = false;
  final TextEditingController _offerController = TextEditingController();
  Auction? auction; // Asta che verrà caricata
  bool isLoading = true; // Stato di caricamento
  bool isError = false; // Per gestire eventuali errori di caricamento
  double? highestBid; // Variabile per l'offerta più alta

  @override
  void initState() {
    super.initState();
    _loadAuctionDetails();
  }

  Future<void> _loadAuctionDetails() async {
    final auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
    final sellerProvider = Provider.of<SellerProvider>(context, listen: false);
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final bidProvider = Provider.of<BidProvider>(context, listen: false);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    if (token != null) {
      print('Token: $token'); // Debug

      try {
        // Carica l'asta
        Auction? fetchedAuction = await auctionProvider.fetchAuctionById(token, widget.auctionId);
        if (fetchedAuction != null) {
          setState(() {
            auction = fetchedAuction;
            _isFavorite = favoritesProvider.isFavorite(auction!); // Verifica se l'asta è nei preferiti
          });

          // Carica le offerte
          await bidProvider.fetchBidsByProduct(token, auction!.prodottoId);

          // Trova l'offerta più alta
          if (bidProvider.bids.isNotEmpty) {
            highestBid = bidProvider.bids.map((bid) => bid.importo).reduce((a, b) => a > b ? a : b);
          }

          setState(() {
            isLoading = false;
          });

          // Recupera i dettagli del venditore collegato al prodotto
          if (fetchedAuction.venditoreId != 0) {
            await sellerProvider.fetchSellerDetails(token, fetchedAuction.venditoreId);
          }
        } else {
          setState(() {
            isError = true; // Se l'asta non viene trovata
            isLoading = false;
          });
        }
      } catch (e) {
        print('Errore nel caricamento dell\'asta: $e');
        setState(() {
          isError = true; // Gestione degli errori
          isLoading = false;
        });
      }
    } else {
      print('Token non disponibile'); // Debug
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _submitBid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken'); // Recupera il token salvato

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token non trovato, effettua il login')),
      );
      return;
    }

    final double? bidAmount = double.tryParse(_offerController.text);
    if (bidAmount == null || bidAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci un importo valido')),
      );
      return;
    }

    final bidProvider = Provider.of<BidProvider>(context, listen: false);
    final bidData = {
      'prodotto_id': auction!.prodottoId,  // ID del prodotto
      'auction_id': widget.auctionId,      // ID dell'asta
      'importo': bidAmount,                // Importo dell'offerta
    };

    try {
      await bidProvider.createBid(token, bidData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offerta inviata con successo!')),
      );
      _offerController.clear();  // Pulisce il campo offerta

      // Ricarica i dettagli dell'asta e delle offerte
      await _loadAuctionDetails();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore durante l\'invio dell\'offerta')),
      );
    }
  }

  void _toggleFavorite() {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    if (auction != null) {
      setState(() {
        _isFavorite = !_isFavorite;
        if (_isFavorite) {
          favoritesProvider.addFavorite(auction!);
        } else {
          favoritesProvider.removeFavorite(auction!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sellerProvider = Provider.of<SellerProvider>(context);
    final seller = sellerProvider.seller; // Recupera il venditore dal provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Prodotto'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? const Center(child: Text('Errore nel caricamento dei dettagli del prodotto'))
          : auction == null
          ? const Center(child: Text('Nessun dettaglio disponibile'))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Immagine principale del prodotto
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      auction?.productImage != null
                          ? auction!.productImage!
                          : 'images/300.png', // Immagine di fallback
                      height: 250.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              // Categoria del prodotto
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  auction?.categoryName ?? 'N/A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ),
              const SizedBox(height: 14.0),
              // Nome e descrizione del prodotto
              Text(
                auction?.productName ?? 'Nome del prodotto',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                auction?.productDescription ?? 'Descrizione non disponibile',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 16.0),
              // Offerta attuale e tempo rimanente
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    highestBid != null && highestBid! > auction!.prezzoIniziale
                        ? 'Offerta più alta: ${highestBid!.toStringAsFixed(2)}€'
                        : 'Offerta attuale: ${auction!.prezzoIniziale.toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'Tempo rimanente: ${_calculateRemainingTime(auction?.dataScadenza)}',
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Fai un\'offerta',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _offerController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white54,
                  border: OutlineInputBorder(),
                  labelText: 'Inserisci la tua offerta',
                  prefixIcon: Icon(Icons.euro, color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  hintStyle: TextStyle(color: Colors.blueGrey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  await _submitBid();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Fai un\'offerta',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 24.0),
              // Dettagli del venditore
              const Text(
                'Venditore',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              seller == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListTile(
                leading: CircleAvatar(
                  backgroundImage: seller.avatar != null
                      ? NetworkImage(seller.avatar!)
                      : const AssetImage('images/user_avatar.png') as ImageProvider,
                ),
                title: Text(seller.nome ?? 'Nome del Venditore'),
                subtitle: const Text('Visualizza profilo'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SellerProfilePage(venditoreId: seller.id),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Costi di Spedizione',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                '€ 10 per la spedizione standard.',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Opzioni di Pagamento',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset(
                    'images/visa.svg',
                    width: 50,
                    height: 50,
                  ),
                  SvgPicture.asset(
                    'images/google_pay.svg',
                    width: 50,
                    height: 50,
                  ),
                  SvgPicture.asset(
                    'images/paypal.svg',
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Funzione per calcolare il tempo rimanente
  String _calculateRemainingTime(DateTime? endTime) {
    if (endTime == null) return 'N/A';
    final currentTime = DateTime.now();
    final remainingDuration = endTime.difference(currentTime);

    if (remainingDuration.isNegative) {
      return 'Asta scaduta';
    } else {
      final hours = remainingDuration.inHours;
      final minutes = remainingDuration.inMinutes % 60;
      return '$hours ore e $minutes minuti rimanenti';
    }
  }
}
