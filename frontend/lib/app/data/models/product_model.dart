class Product {
  final int id;
  final String nome;
  final String descrizione;
  final double prezzoIniziale;
  final String? immaginePrincipale;
  final int? categoriaId;
  final String? categoryName;
  final int venditoreId;
  final String? venditoreNome;
  final String? venditoreCognome;

  Product({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.prezzoIniziale,
    this.immaginePrincipale,
    this.categoriaId,
    this.categoryName,
    required this.venditoreId,
    this.venditoreNome,
    this.venditoreCognome,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Nome non disponibile',
      descrizione: json['descrizione'] ?? 'Descrizione non disponibile',
      prezzoIniziale: double.tryParse(json['prezzo_iniziale'].toString()) ?? 0.0,
      immaginePrincipale: json['immagine_principale'],
      categoriaId: json['categoria_id'] != null ? json['categoria_id'] as int : null,
      categoryName: json['Category'] != null ? json['Category']['nome'] : 'N/A',
      venditoreId: json['venditore_id'] ?? 0,
      venditoreNome: json['venditore_nome'] ?? 'Nome non disponibile',
      venditoreCognome: json['venditore_cognome'] ?? 'Cognome non disponibile',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descrizione': descrizione,
      'immagine_principale': immaginePrincipale,
      'categoria_id': categoriaId,
      'categoryName': categoryName,
      'venditore_id': venditoreId,
      'venditore_nome': venditoreNome,
      'venditore_cognome': venditoreCognome,
    };
  }
}
