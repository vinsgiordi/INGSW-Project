class NotificationModel {
  final int id;
  final int utenteId;
  final String messaggio;
  final bool letto;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.utenteId,
    required this.messaggio,
    required this.letto,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      utenteId: json['utente_id'],
      messaggio: json['messaggio'],
      letto: json['letto'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utente_id': utenteId,
      'messaggio': messaggio,
      'letto': letto,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
