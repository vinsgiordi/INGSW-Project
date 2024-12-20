import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/provider/user_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Funzione per resettare la password
  Future<void> resetPassword(BuildContext context) async {
    final email = emailController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le password non coincidono')),
      );
      return;
    }

    try {
      // Chiamata all'API per aggiornare la password
      await Provider.of<UserProvider>(context, listen: false).resetPassword(email, newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password aggiornata con successo!')),
      );

      // Reindirizza alla pagina di login
      Navigator.pushReplacementNamed(context, '/login');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nell\'aggiornamento della password: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30.0), // Altezza personalizzata
        child: AppBar(
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              margin: const EdgeInsets.all(0),
              color: Colors.blue,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 10),
                    child: Container(
                      height: 200, // Dimensione per il logo
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/logo.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Password Dimenticata',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          height: 3,
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            margin: const EdgeInsets.all(0),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(), // Disabilita lo scroll
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue[50],
                        labelText: 'Email',
                        hintText: 'Inserisci la tua email',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email, color: Colors.blue),
                        labelStyle: const TextStyle(color: Colors.blue),
                        hintStyle: const TextStyle(color: Colors.blueGrey),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                      ),
                      style: const TextStyle(color: Colors.blue),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: newPasswordController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue[50],
                        labelText: 'Nuova Password',
                        hintText: 'Inserisci la tua nuova password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                        labelStyle: const TextStyle(color: Colors.blue),
                        hintStyle: const TextStyle(color: Colors.blueGrey),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                      ),
                      obscureText: !_isNewPasswordVisible,
                      style: const TextStyle(color: Colors.blue),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue[50],
                        labelText: 'Conferma Password',
                        hintText: 'Conferma la tua nuova password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                        labelStyle: const TextStyle(color: Colors.blue),
                        hintStyle: const TextStyle(color: Colors.blueGrey),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                      ),
                      obscureText: !_isConfirmPasswordVisible,
                      style: const TextStyle(color: Colors.blue),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        resetPassword(context); // Richiama la funzione di reset
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Avanti',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        'images/forgot_password.png', // Immagine footer
                        height: 300, // Altezza immagine
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
