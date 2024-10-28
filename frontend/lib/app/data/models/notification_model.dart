class NotificationModel {
  final int id;
  final int userId;
  final String message;
  final bool isRead;
  final int? auctionId;
  final int? bidId;
  final bool isInteractive;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.isRead,
    this.auctionId,
    this.bidId,
    this.isInteractive = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['utente_id'],
      message: json['messaggio'],
      isRead: json['letto'] ?? false,
      auctionId: json['auction_id'],
      bidId: json['bid_id'],
      isInteractive: json['auction_id'] != null, // True se l'asta è associata
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utente_id': userId,
      'messaggio': message,
      'letto': isRead,
      'auction_id': auctionId,
      'bid_id': bidId,
    };
  }
}
