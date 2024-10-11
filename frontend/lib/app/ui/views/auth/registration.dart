import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/registration_controller.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  @override
  Widget build(BuildContext context) {
    // Accedi al RegistrationController tramite Provider
    final registrationController = Provider.of<RegistrationController>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
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
                      height: 200,
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
                            'Registrazione',
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
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: registrationController.firstNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue[50],
                        labelText: 'Nome',
                        hintText: 'Inserisci il tuo nome',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person, color: Colors.blue),
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
                      controller: registrationController.lastNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue[50],
                        labelText: 'Cognome',
                        hintText: 'Inserisci il tuo cognome',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person, color: Colors.blue),
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
                      controller: registrationController.birthDateController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue[50],
                        labelText: 'Data di Nascita',
                        hintText: 'Inserisci la tua data di nascita',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
                        labelStyle: const TextStyle(color: Colors.blue),
                        hintStyle: const TextStyle(color: Colors.blueGrey),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                      ),
                      keyboardType: TextInputType.datetime,
                      style: const TextStyle(color: Colors.blue),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: registrationController.emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue[50],
                        labelText: 'Indirizzo e-mail',
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
                      controller: registrationController.passwordController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue[50],
                        labelText: 'Password',
                        hintText: 'Inserisci la tua password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        suffixIcon: const Icon(Icons.visibility_off, color: Colors.blue),
                        labelStyle: const TextStyle(color: Colors.blue),
                        hintStyle: const TextStyle(color: Colors.blueGrey),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                      ),
                      obscureText: true,
                      style: const TextStyle(color: Colors.blue),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Richiama la funzione di registrazione
                        registrationController.registerUser(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: registrationController.isLoading
                          ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                          : const Text(
                        'Registrati',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        // Naviga alla schermata di login
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        'Hai già un account? Accedi subito',
                        style: TextStyle(color: Colors.blue),
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
