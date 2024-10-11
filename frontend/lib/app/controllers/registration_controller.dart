import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/provider/user_provider.dart';

class RegistrationController with ChangeNotifier {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Funzione per effettuare la registrazione
  Future<void> registerUser(BuildContext context) async {
    final firstName = firstNameController.text;
    final lastName = lastNameController.text;
    final birthDate = birthDateController.text;
    final email = emailController.text;
    final password = passwordController.text;

    if (firstName.isEmpty || lastName.isEmpty || birthDate.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compila tutti i campi')),
      );
      return;
    }

    // Prepariamo i dati da inviare all'API
    final Map<String, dynamic> userData = {
      'nome': firstName,
      'cognome': lastName,
      'data_nascita': birthDate,
      'email': email,
      'password': password,
    };

    try {
      _isLoading = true;
      notifyListeners();

      // Chiama la funzione register del UserProvider per registrare l'utente
      await Provider.of<UserProvider>(context, listen: false).register(userData);

      _isLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrazione avvenuta con successo!')),
      );

      // Reindirizza l'utente alla pagina di login o home
      Navigator.pushReplacementNamed(context, '/login');
    } catch (error) {
      _isLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nella registrazione: $error')),
      );
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    birthDateController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
