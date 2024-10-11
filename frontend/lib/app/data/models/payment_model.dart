class Payment {
  final int id;
  final int utenteId;
  final String numeroCarta;
  final String nomeIntestatario;
  final DateTime dataScadenza;

  Payment({
    required this.id,
    required this.utenteId,
    required this.numeroCarta,
    required this.nomeIntestatario,
    required this.dataScadenza,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      utenteId: json['utente_id'],
      numeroCarta: json['numero_carta'],
      nomeIntestatario: json['nome_intestatario'],
      dataScadenza: DateTime.parse(json['data_scadenza']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utente_id': utenteId,
      'numero_carta': numeroCarta,
      'nome_intestatario': nomeIntestatario,
      'data_scadenza': dataScadenza.toIso8601String(),
    };
  }
}
