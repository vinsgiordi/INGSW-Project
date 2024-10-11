import 'package:bid_hub/app/data/provider/bid_provider.dart';
import 'package:bid_hub/app/data/provider/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/routes/app_routes.dart';
import 'app/globals.dart';
import 'app/controllers/registration_controller.dart';
import 'app/data/provider/user_provider.dart';
import 'app/data/provider/payment_provider.dart';
import 'app/data/provider/notification_provider.dart';
import 'app/data/provider/auction_provider.dart';
import 'app/data/provider/category_provider.dart';
import 'app/data/provider/seller_provider.dart';
import 'app/data/provider/favorites_provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(  // Usa MultiProvider per includere UserProvider
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),  // Provider per l'utente
        ChangeNotifierProvider(create: (_) => RegistrationController()), // Provider per la registrazione utente
        ChangeNotifierProvider(create: (_) => PaymentProvider()), // Provider per il pagamento
        ChangeNotifierProvider(create: (_) => NotificationProvider()), // Provider per le notifiche
        ChangeNotifierProvider(create: (_) => AuctionProvider()), // Provider per le aste
        ChangeNotifierProvider(create: (_) => BidProvider()), // Provider per le offerte
        ChangeNotifierProvider(create: (_) => CategoryProvider()), // Provider per le categorie
        ChangeNotifierProvider(create: (_) => SellerProvider()), // Provider per il venditore
        ChangeNotifierProvider(create: (_) => FavoritesProvider()), // Provider per i preferiti
        ChangeNotifierProvider(create: (_) => SearchProvider()), // Provider per la ricerca
      ],
      child: MaterialApp(
        title: 'BidHub',
        theme: AppTheme.themeData,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.welcome,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
