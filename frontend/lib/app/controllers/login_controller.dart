import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/provider/user_provider.dart';
import '../data/provider/social_login_provider.dart';

class LoginController with ChangeNotifier {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cognomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dataNascitaController = TextEditingController();
  final TextEditingController shortBioController = TextEditingController();
  final TextEditingController indirizzoController = TextEditingController();
  final TextEditingController sitoWebController = TextEditingController();
  final TextEditingController socialLinksController = TextEditingController();
  final TextEditingController posizioneGeograficaController = TextEditingController();

  bool _passwordVisible = false;

  bool get passwordVisible => _passwordVisible;

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  // Funzione di login tramite UserProvider
  Future<void> login(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compila tutti i campi')),
      );
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.login(email, password);

      // Dopo il login, reindirizza l'utente alla home
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenziali non valide')),
      );
    }
  }

  // Funzione per aggiornare i dati dell'utente
  Future<void> updateUser(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utente non autenticato')),
      );
      return;
    }

    try {
      await userProvider.updateUser(token, {
        'nome': nomeController.text,
        'cognome': cognomeController.text,
        'email': emailController.text,
        'data_nascita': dataNascitaController.text,
        'short_bio': shortBioController.text,
        'indirizzo': indirizzoController.text,
        'sito_web': sitoWebController.text,
        'social_links': socialLinksController.text,
        'posizione_geografica': posizioneGeograficaController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profilo aggiornato con successo')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nell\'aggiornamento del profilo')),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Elimina tutti i token

    // Reindirizza alla pagina di login
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Funzione per il login social usando SocialLoginProvider
  Future<void> loginWithSocial(BuildContext context, String provider) async {
    try {
      final socialLoginProvider = Provider.of<SocialLoginProvider>(context, listen: false);
      await socialLoginProvider.loginWithSocial(provider, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il login social: $e')),
      );
    }
  }


  @override
  void dispose() {
    nomeController.dispose();
    cognomeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    dataNascitaController.dispose();
    shortBioController.dispose();
    indirizzoController.dispose();
    sitoWebController.dispose();
    socialLinksController.dispose();
    posizioneGeograficaController.dispose();
    super.dispose();
  }
}
