import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/models/auction_model.dart';
import '../data/provider/auction_provider.dart';
import '../data/provider/favorites_provider.dart';
import '../data/provider/seller_provider.dart';
import '../data/provider/bid_provider.dart';
import 'seller_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatefulWidget {
  final int auctionId;

  const ProductDetailPage({required this.auctionId, Key? key}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isFavorite = false;
  final TextEditingController _offerController = TextEditingController();
  Auction? auction;
  bool isLoading = true;
  bool isError = false;
  double? highestBid;
  bool _isUserSeller = false;
  Timer? _refreshTimer; // Timer per aggiornare il prezzo

  @override
  void initState() {
    super.initState();
    _loadAuctionDetails();
    _checkIfUserIsSeller();
    _startPriceRefreshTimer(); // Inizia il timer per aggiornare il prezzo
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Ferma il timer quando la pagina viene chiusa
    _offerController.dispose();
    super.dispose();
  }

  Future<void> _startPriceRefreshTimer() async {
    // Aggiorna il prezzo ogni minuto (o altra frequenza desiderata)
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _updateCurrentPrice(); // Aggiorna il prezzo ogni minuto
    });
  }

  Future<void> _updateCurrentPrice() async {
    if (auction?.tipo == 'ribasso' && auction != null) {
      try {
        final auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('accessToken');

        if (token != null) {
          Auction? updatedAuction = await auctionProvider.fetchAuctionById(token, widget.auctionId);
          if (updatedAuction != null && mounted) {
            setState(() {
              auction = updatedAuction; // Aggiorna solo i dettagli dell'asta con il nuovo prezzo
            });
          }
        }
      } catch (e) {
        print('Errore durante l\'aggiornamento del prezzo: $e');
      }
    }
  }

  Future<void> _checkIfUserIsSeller() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    if (token != null) {
      bool isSeller = await Provider.of<AuctionProvider>(context, listen: false)
          .verifyUserIsSeller(token, widget.auctionId);
      setState(() {
        _isUserSeller = isSeller; // Assegna il risultato a `_isUserSeller`
      });
    }
  }

  Future<void> _loadAuctionDetails() async {
    final auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
    final sellerProvider = Provider.of<SellerProvider>(context, listen: false);
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final bidProvider = Provider.of<BidProvider>(context, listen: false);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    if (token != null) {
      try {
        Auction? fetchedAuction = await auctionProvider.fetchAuctionById(token, widget.auctionId);
        if (fetchedAuction != null) {
          setState(() {
            auction = fetchedAuction;
            _isFavorite = favoritesProvider.isFavorite(auction!);
          });

          if (auction!.tipo != 'silenziosa') {
            await bidProvider.fetchBidsByProduct(token, auction!.prodottoId);
            if (bidProvider.bids.isNotEmpty) {
              highestBid = bidProvider.bids.map((bid) => bid.importo).reduce((a, b) => a > b ? a : b);
            }
          }

          setState(() {
            isLoading = false;
          });

          if (fetchedAuction.venditoreId != 0) {
            await sellerProvider.fetchSellerDetails(token, fetchedAuction.venditoreId);
          }
        } else {
          setState(() {
            isError = true;
            isLoading = false;
          });
        }
      } catch (e) {
        print('Errore nel caricamento dell\'asta: $e');
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } else {
      print('Token non disponibile');
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
    print('venditoreId: ${auction?.venditoreId}, stato: ${auction?.stato}');
  }

  Future<void> _submitBid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

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

    // Soglia minima di rialzo
    final double minIncrement = auction?.incrementoRialzo ?? 10.0;
    final double minRequiredBid = (highestBid ?? auction!.prezzoIniziale) + minIncrement;

    // Controllo della soglia di rialzo
    if (bidAmount < minRequiredBid) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Offerta troppo bassa'),
            content: Text(
                'La soglia minima di rialzo è di €${minIncrement.toStringAsFixed(2)}. L\'offerta deve essere almeno €${minRequiredBid.toStringAsFixed(2)}.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Creazione dell'offerta
    final bidProvider = Provider.of<BidProvider>(context, listen: false);
    final bidData = {
      'prodotto_id': auction!.prodottoId,
      'auction_id': widget.auctionId,
      'importo': bidAmount,
    };

    try {
      await bidProvider.createBid(token, bidData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offerta inviata con successo!')),
      );
      _offerController.clear();
      await _loadAuctionDetails(); // Aggiorna i dettagli dell'asta e l'offerta più alta
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

  bool get _canSubmitBid {
    if (auction == null) return false;
    final isAuctionExpired = DateTime.now().isAfter(auction!.dataScadenza);
    final isAuctionCompleted = auction!.stato == 'completata';

    final canBid = !isAuctionExpired && !_isUserSeller && !isAuctionCompleted;
    return canBid;
  }

  @override
  Widget build(BuildContext context) {
    final sellerProvider = Provider.of<SellerProvider>(context);
    final seller = sellerProvider.seller;

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
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: auction?.productImage != null
                        ? Image.memory(
                      base64Decode(auction!.productImage!),
                      height: 250.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'images/300.png',
                      height: 250.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20.0),
              Row(
                children: [
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
                  const SizedBox(width: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      toBeginningOfSentenceCase(auction?.tipo ?? 'Tipo N/A')!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (auction!.tipo != 'silenziosa')
                    Text(
                      highestBid != null && highestBid! > auction!.prezzoIniziale
                          ? 'Offerta più alta: ${highestBid!.toStringAsFixed(2)}€'
                          : 'Offerta attuale: ${auction!.prezzoIniziale.toStringAsFixed(2)}€',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    )
                  else
                    Text(
                      'Offerta attuale: ${auction!.prezzoIniziale.toStringAsFixed(2)}€',
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
                _calculateRemainingTime(auction?.dataScadenza),
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24.0),
              if (_canSubmitBid) ...[
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
                  onPressed: _submitBid,
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
              ],
              const SizedBox(height: 24.0),
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
                title: Text(seller.nome),
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

  String _calculateRemainingTime(DateTime? endTime) {

    if (auction?.stato == 'completata' || (endTime != null && DateTime.now().isAfter(endTime))) {
      return 'Tempo rimanente: Asta terminata';
    }

    if (endTime == null) return 'N/A';

    final currentTime = DateTime.now();
    final remainingDuration = endTime.difference(currentTime);

    final hours = remainingDuration.inHours;
    final minutes = remainingDuration.inMinutes % 60;

    return 'Tempo rimanente: $hours ore e $minutes minuti';
  }

}
