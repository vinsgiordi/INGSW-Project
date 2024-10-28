import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Imposta lo sfondo bianco
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 40), // Spazio sopra il logo
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('images/logo.png'), // Logo
                  ),
                  SizedBox(width: 10), // Spazio tra logo e testo
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Benvenuto in DietiDeals24',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700], // Colore blu
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'La piattaforma di aste online più affidabile e sicura. Inizia a fare offerte sui tuoi prodotti preferiti ora!',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue, // Colore blu
                ),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Naviga alla schermata di login
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue, // Colore del testo del bottone
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('Inizia'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
