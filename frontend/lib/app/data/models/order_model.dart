class Order {
  final int prodottoId;
  final int acquirenteId;
  final int venditoreId;
  final String stato;
  final String indirizzoSpedizione;
  final String metodoPagamento;
  final double importoTotale;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.prodottoId,
    required this.acquirenteId,
    required this.venditoreId,
    required this.stato,
    required this.indirizzoSpedizione,
    required this.metodoPagamento,
    required this.importoTotale,
    required this.createdAt,
    required this.updatedAt,
  });

  // Funzione per convertire JSON in oggetto Order
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      prodottoId: json['prodotto_id'],
      acquirenteId: json['acquirente_id'],
      venditoreId: json['venditore_id'],
      stato: json['stato'],
      indirizzoSpedizione: json['indirizzo_spedizione'],
      metodoPagamento: json['metodo_pagamento'],
      importoTotale: json['importo_totale'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Funzione per convertire l'oggetto Order in JSON
  Map<String, dynamic> toJson() {
    return {
      'prodotto_id': prodottoId,
      'acquirente_id': acquirenteId,
      'venditore_id': venditoreId,
      'stato': stato,
      'indirizzo_spedizione': indirizzoSpedizione,
      'metodo_pagamento': metodoPagamento,
      'importo_totale': importoTotale,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
