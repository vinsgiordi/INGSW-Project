import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../components/product_detail.dart';
import '../../../../data/models/auction_model.dart';
import '../../../../data/provider/bid_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBidsPage extends StatefulWidget {
  @override
  _MyBidsPageState createState() => _MyBidsPageState();
}

class _MyBidsPageState extends State<MyBidsPage> with AutomaticKeepAliveClientMixin {
  bool isLoading = true;
  bool isError = false;
  String? _currentUserToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBids();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBids();  // Carica nuovamente le offerte quando le dipendenze cambiano
  }

  @override
  void didUpdateWidget(covariant MyBidsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadBids();
  }

  @override
  void dispose() {
    // Assicurati di chiamare il dispose super.
    super.dispose();
  }

  Future<void> _loadBids() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUserToken = prefs.getString('accessToken'); // Recupera il token da SharedPreferences

    if (_currentUserToken != null) {
      try {
        await Provider.of<BidProvider>(context, listen: false).fetchBidsByUser(_currentUserToken!);

        // Controlla se il widget è ancora montato prima di chiamare setState
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        print('Errore nel caricamento delle offerte: $e');
        if (!mounted) return;
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } else {
      print('Token non disponibile');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);  // Required when using AutomaticKeepAliveClientMixin
    final bidProvider = Provider.of<BidProvider>(context);
    final bids = bidProvider.bids;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le mie offerte'),
        automaticallyImplyLeading: true, // Mostra il pulsante "indietro"
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? const Center(child: Text('Errore nel caricamento delle offerte'))
          : bids.isEmpty
          ? const Center(child: Text('Nessuna offerta trovata.'))
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: bids.length,
        itemBuilder: (context, index) {
          final bid = bids[index];
          Auction? auction = bid.auction;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(auctionId: auction!.id),
                ),
              );
            },
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    auction?.productImage ?? 'images/150.png', // Usa una risorsa locale se l'immagine è assente
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(auction?.productName ?? 'Titolo non disponibile'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auction?.productDescription ?? 'Descrizione non disponibile'),
                    const SizedBox(height: 4.0),
                    Text(
                      'Offerta: €${bid.importo.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    print('Eliminazione dell\'offerta con ID: ${bid.id}');
                    _deleteBid(bid.id);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteBid(int bidId) async {
    try {
      print('Tentativo di eliminazione dell\'offerta con ID: $bidId');
      await Provider.of<BidProvider>(context, listen: false).deleteBid(_currentUserToken!, bidId);
      print('Offerta eliminata con successo');
    } catch (e) {
      print('Errore durante l\'eliminazione dell\'offerta: $e');
    }
  }

  @override
  bool get wantKeepAlive => true;  // Mantiene lo stato della pagina anche quando si naviga avanti e indietro
}
