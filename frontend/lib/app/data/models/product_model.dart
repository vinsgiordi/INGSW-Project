class Product {
  final int id;
  final String nome;
  final String descrizione;
  final double prezzoIniziale;
  final String? immaginePrincipale;
  final int? categoriaId; // Cambia categoriaId per gestire i valori null
  final String? categoryName; // Nome della categoria
  final int venditoreId;
  final String? venditoreNome;
  final String? venditoreCognome;

  Product({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.prezzoIniziale,
    this.immaginePrincipale,
    this.categoriaId, // Ora è nullable
    this.categoryName,
    required this.venditoreId,
    this.venditoreNome,
    this.venditoreCognome,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0, // Fallback per id null
      nome: json['nome'] ?? 'Nome non disponibile', // Fallback per nome null
      descrizione: json['descrizione'] ?? 'Descrizione non disponibile', // Fallback per descrizione null
      prezzoIniziale: double.tryParse(json['prezzo_iniziale'].toString()) ?? 0.0,
      immaginePrincipale: json['immagine_principale'],
      categoriaId: json['categoria_id'] != null ? json['categoria_id'] as int : null, // Categoria ID
      categoryName: json['Category'] != null ? json['Category']['nome'] : 'N/A', // Recupera il nome della categoria
      venditoreId: json['venditore_id'] ?? 0, // Fallback per venditore_id null
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
      'categoryName': categoryName, // Include anche il nome della categoria
      'venditore_id': venditoreId,
      'venditore_nome': venditoreNome,
      'venditore_cognome': venditoreCognome,
    };
  }
}
