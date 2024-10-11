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
      id: json['id'],
      prodottoId: json['prodotto_id'],
      utenteId: json['utente_id'],
      importo: json['importo'] is String ? double.tryParse(json['importo']) ?? 0.0 : json['importo'].toDouble(),
      auction: json['auction'] != null ? Auction.fromJson(json['auction']) : null,
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
