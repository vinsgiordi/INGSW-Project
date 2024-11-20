import 'bid_model.dart';

class Auction {
  final int id;
  final int prodottoId;
  final String tipo;
  final DateTime dataScadenza;
  final double? prezzoMinimo;
  final double? incrementoRialzo;
  final double? decrementoPrezzo;
  final double prezzoIniziale;
  final String? immaginePrincipale;
  final String stato;
  final int venditoreId;
  String? sellerName;
  // Dettagli del prodotto
  final String? productName;
  final String? productDescription;
  final String? productImage;
  String? categoryName;
  final List<Bid>? bids;

  Auction({
    required this.id,
    required this.prodottoId,
    required this.tipo,
    required this.dataScadenza,
    this.prezzoMinimo,
    this.incrementoRialzo,
    this.decrementoPrezzo,
    required this.prezzoIniziale,
    this.immaginePrincipale,
    required this.stato,
    required this.venditoreId,
    this.sellerName,
    this.productName,
    this.productDescription,
    this.productImage,
    this.categoryName,
    this.bids,
  });

  factory Auction.fromJson(Map<String, dynamic> json) {
    return Auction(
      id: json['id'] ?? 0,
      prodottoId: json['prodotto_id'] ?? 0,
      tipo: json['tipo'] ?? '',
      dataScadenza: DateTime.parse(json['data_scadenza']),
      prezzoMinimo: json['prezzo_minimo'] != null ? double.tryParse(json['prezzo_minimo'].toString()) ?? 0.0 : null,
      incrementoRialzo: json['incremento_rialzo'] != null ? double.tryParse(json['incremento_rialzo'].toString()) ?? 0.0 : null,
      decrementoPrezzo: json['decremento_prezzo'] != null ? double.tryParse(json['decremento_prezzo'].toString()) ?? 0.0 : null,
      prezzoIniziale: double.tryParse(json['prezzo_iniziale'].toString()) ?? 0.0,
      immaginePrincipale: json['immagine_principale'],
      stato: json['stato'] ?? '',
      venditoreId: json['venditore_id'] ?? 0,
      sellerName: json['Product'] != null && json['Product']['venditore'] != null
          ? "${json['Product']['venditore']['nome']} ${json['Product']['venditore']['cognome']}"
          : null,
      productName: json['Product'] != null ? json['Product']['nome'] : null,
      productDescription: json['Product'] != null ? json['Product']['descrizione'] : null,
      productImage: json['Product'] != null ? json['Product']['immagine_principale'] : null,
      categoryName: json['Product'] != null && json['Product']['Category'] != null ? json['Product']['Category']['nome'] : 'N/A',
      bids: json['Bids'] != null ? List<Bid>.from(json['Bids'].map((bidJson) => Bid.fromJson(bidJson))) : [],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prodotto_id': prodottoId,
      'tipo': tipo,
      'data_scadenza': dataScadenza.toIso8601String(),
      'prezzo_minimo': prezzoMinimo,
      'incremento_rialzo': incrementoRialzo,
      'decremento_prezzo': decrementoPrezzo,
      'prezzo_iniziale': prezzoIniziale,
      'immagine_principale': immaginePrincipale,
      'stato': stato,
      'venditore_id': venditoreId,
      'sellerName': sellerName,
      // Dati relativi al prodotto
      'productName': productName,
      'productDescription': productDescription,
      'productImage': productImage,
      'categoryName': categoryName,
      'Bids': bids != null ? bids!.map((bid) => bid.toJson()).toList() : [],
    };
  }
}
