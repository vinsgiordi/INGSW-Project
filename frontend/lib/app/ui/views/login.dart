import 'package:bid_hub/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bid_hub/app/controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginController(),
      child: Scaffold(
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
                      padding: const EdgeInsets.all(55),
                      child: Container(
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
                              'Login',
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
                physics: const NeverScrollableScrollPhysics(), // Disabilitato lo scroll
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  child: Column(
                    children: [
                      Consumer<LoginController>(
                        builder: (context, controller, child) => Column(
                          children: [
                            TextField(
                              controller: controller.emailController,
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
                              controller: controller.passwordController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.blue[50],
                                labelText: 'Password',
                                hintText: 'Inserisci la tua password',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.blue,
                                  ),
                                  onPressed: controller.togglePasswordVisibility,
                                ),
                                labelStyle: const TextStyle(color: Colors.blue),
                                hintStyle: const TextStyle(color: Colors.blueGrey),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.blue),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.blueGrey),
                                ),
                              ),
                              obscureText: !controller.passwordVisible,
                              style: const TextStyle(color: Colors.blue),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.forgotPassword);
                                },
                                child: const Text(
                                  'Password dimenticata?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Consumer<LoginController>(
                        builder: (context, controller, child) => ElevatedButton(
                          onPressed: () {
                            controller.login(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Colore blu per il bottone
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Accedi con',
                        style: TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: Image.asset('images/google_icon.png'), // Icona per Google
                              onPressed: () {
                                // Azione per il login con Google
                              },
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: Image.asset('images/facebook_icon.png'), // Icona per Facebook
                              onPressed: () {
                                // Azione per il login con Facebook
                              },
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: Image.asset('images/github_icon.png'), // Icona per GitHub
                              onPressed: () {
                                // Azione per il login con GitHub
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Column(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.registration);
                            },
                            child: const Text(
                              'Non hai un account? Registrati subito',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Image.asset(
                                'images/omino_login.jpg', // Immagine footer
                                height: 190, // Altezza immagine
                                fit: BoxFit.contain,
                              ),
                              const Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
