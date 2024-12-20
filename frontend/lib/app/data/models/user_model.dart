import 'package:intl/intl.dart';

class User {
  final int id;
  final String nome;
  final String cognome;
  final String email;
  final String? password;
  final String? dataNascita;
  final String? shortBio;
  final String? indirizzoDiSpedizione;
  final String? indirizzoDiFatturazione;
  final String? sitoWeb;
  final Map<String, String>? socialLinks;
  final String? posizioneGeografica;
  final String? socialId;
  final String? socialProvider;
  final String? avatar;

  User({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.email,
    this.password,
    this.dataNascita,
    this.shortBio,
    this.indirizzoDiSpedizione,
    this.indirizzoDiFatturazione,
    this.sitoWeb,
    this.socialLinks,
    this.posizioneGeografica,
    this.socialId,
    this.socialProvider,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String? formattedDate;
    if (json['data_nascita'] != null) {
      final date = DateTime.parse(json['data_nascita']);
      formattedDate = DateFormat('yyyy-MM-dd').format(date);
    }

    return User(
      id: json['id'] != null ? json['id'] as int : 0,
      nome: json['nome'] ?? 'Nome non disponibile',
      cognome: json['cognome'] ?? 'Cognome non disponibile',
      email: json['email'] ?? 'Email non disponibile',
      password: json['password'],
      dataNascita: formattedDate,
      shortBio: json['short_bio'],
      indirizzoDiSpedizione: json['indirizzo_di_spedizione'],
      indirizzoDiFatturazione: json['indirizzo_di_fatturazione'],
      sitoWeb: json['sito_web'],
      socialLinks: json['social_links'] != null
          ? Map<String, String>.from(json['social_links'])
          : null,
      posizioneGeografica: json['posizione_geografica'],
      socialId: json['social_id'],
      socialProvider: json['social_provider'],
      avatar: json['avatar'] != null ? json['avatar'] as String : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cognome': cognome,
      'email': email,
      'password': password,
      'data_nascita': dataNascita,
      'short_bio': shortBio,
      'indirizzo_di_spedizione': indirizzoDiSpedizione,
      'indirizzo_di_fatturazione': indirizzoDiFatturazione,
      'sito_web': sitoWeb,
      'social_links': socialLinks,
      'posizione_geografica': posizioneGeografica,
      'social_id': socialId,
      'social_provider': socialProvider,
      'avatar': avatar,
    };
  }
}