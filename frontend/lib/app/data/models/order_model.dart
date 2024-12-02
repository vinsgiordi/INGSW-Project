import 'product_model.dart';

class Order {
  final int? id;
  final int prodottoId;
  final int acquirenteId;
  final int venditoreId;
  final String stato;
  final String indirizzoSpedizione;
  final String metodoPagamento;
  final double importoTotale;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int auctionId;
  final Product? product;

  Order({
    required this.id,
    required this.prodottoId,
    required this.acquirenteId,
    required this.venditoreId,
    required this.stato,
    required this.indirizzoSpedizione,
    required this.metodoPagamento,
    required this.importoTotale,
    required this.createdAt,
    required this.updatedAt,
    required this.auctionId,
    this.product,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] != null ? json['id'] as int : 0,  // Gestisci il caso in cui 'id' sia null
      prodottoId: json['prodotto_id'],
      acquirenteId: json['acquirente_id'],
      venditoreId: json['venditore_id'],
      stato: json['stato'],
      indirizzoSpedizione: json['indirizzo_spedizione'],
      metodoPagamento: json['metodo_pagamento'],
      importoTotale: double.parse(json['importo_totale'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      auctionId: json['auction_id'],
      product: json['Product'] != null ? Product.fromJson(json['Product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prodotto_id': prodottoId,
      'acquirente_id': acquirenteId,
      'venditore_id': venditoreId,
      'stato': stato,
      'indirizzo_spedizione': indirizzoSpedizione,
      'metodo_pagamento': metodoPagamento,
      'importo_totale': importoTotale,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'auction_id': auctionId,
      'Product': product?.toJson(),
    };
  }
}
