import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import '../../../services/storage_service.dart';

class SocialLoginProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _jwtToken;

  bool get isLoading => _isLoading;
  String? get jwtToken => _jwtToken;

  Future<void> loginWithSocial(String provider, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Effettua l'autenticazione tramite social
      final result = await FlutterWebAuth.authenticate(
        url: 'http://51.20.181.177:3000/auth/$provider',
        callbackUrlScheme: 'bidhub',
      );

      print('Callback result: $result');

      final token = Uri.parse(result).queryParameters['token'];
      print('Token: $token');

      if (token != null) {
        _jwtToken = token;

        // Usa il servizio StorageService per salvare il token
        final storageService = StorageService();
        await storageService.saveAccessToken(_jwtToken!);

        // Controlla se il token è stato salvato correttamente
        final savedToken = await storageService.getAccessToken();
        print("Token salvato: $savedToken");

        // Reindirizza alla home page
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throw Exception('Login fallito: Nessun token ricevuto.');
      }
    } catch (error) {
      print('Errore durante il login social: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il login social: $error')),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _jwtToken = null;
    notifyListeners();
  }
}
