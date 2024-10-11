class Auction {
  final int id;
  final int prodottoId;
  final String tipo;
  final DateTime dataScadenza;
  final double? prezzoMinimo;
  final double? incrementoRialzo;
  final double? decrementoPrezzo;
  final double prezzoIniziale;
  final String stato;
  final int venditoreId;
  String? sellerName;
  // Dettagli del prodotto
  final String? productName;
  final String? productDescription;
  final String? productImage;
  String? categoryName;

  Auction({
    required this.id,
    required this.prodottoId,
    required this.tipo,
    required this.dataScadenza,
    this.prezzoMinimo,
    this.incrementoRialzo,
    this.decrementoPrezzo,
    required this.prezzoIniziale,
    required this.stato,
    required this.venditoreId,
    this.sellerName,
    this.productName,
    this.productDescription,
    this.productImage,
    this.categoryName,
  });

  factory Auction.fromJson(Map<String, dynamic> json) {
    return Auction(
      id: json['id'],
      prodottoId: json['prodotto_id'],
      tipo: json['tipo'],
      dataScadenza: DateTime.parse(json['data_scadenza']),
      prezzoMinimo: json['prezzo_minimo'] != null ? double.tryParse(json['prezzo_minimo'].toString()) ?? 0.0 : null,
      incrementoRialzo: json['incremento_rialzo'] != null ? double.tryParse(json['incremento_rialzo'].toString()) ?? 0.0 : null,
      decrementoPrezzo: json['decremento_prezzo'] != null ? double.tryParse(json['decremento_prezzo'].toString()) ?? 0.0 : null,
      prezzoIniziale: double.tryParse(json['prezzo_iniziale'].toString()) ?? 0.0,
      stato: json['stato'],
      venditoreId: json['venditore_id'] ?? 0,
      sellerName: json['Product'] != null && json['Product']['venditore'] != null
          ? "${json['Product']['venditore']['nome']} ${json['Product']['venditore']['cognome']}"
          : null,      productName: json['Product'] != null ? json['Product']['nome'] : null,
      productDescription: json['Product'] != null ? json['Product']['descrizione'] : null,
      productImage: json['Product'] != null ? json['Product']['immagine_principale'] : null,
      categoryName: json['Product'] != null && json['Product']['Category'] != null
          ? json['Product']['Category']['nome']
          : 'N/A', // Nome della categoria
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
      'stato': stato,
      'venditore_id': venditoreId,
      'sellerName': sellerName,
      // Dati relativi al prodotto
      'productName': productName,
      'productDescription': productDescription,
      'productImage': productImage,
      'categoryName': categoryName,
    };
  }
}