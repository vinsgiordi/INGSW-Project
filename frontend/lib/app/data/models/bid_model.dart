import 'auction_model.dart';

class Bid {
  final int id;
  final int prodottoId;
  final int utenteId;
  final double importo;
  final Auction? auction;

  Bid({
    required this.id,
    required this.prodottoId,
    required this.utenteId,
    required this.importo,
    this.auction,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id'] ?? 0, // Gestisci id null
      prodottoId: json['prodotto_id'] ?? 0, // Gestisci prodottoId null
      utenteId: json['utente_id'] ?? 0, // Gestisci utenteId null
      importo: json['importo'] is String ? double.tryParse(json['importo']) ?? 0.0 : json['importo'].toDouble(),
      auction: json.containsKey('Auction') && json['Auction'] != null
          ? Auction.fromJson(json['Auction'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prodotto_id': prodottoId,
      'utente_id': utenteId,
      'importo': importo,
      'auction': auction?.toJson(),
    };
  }
}
