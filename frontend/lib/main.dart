import 'package:flutter/material.dart';
import 'app/routes/app_routes.dart';
import 'app/globals.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BidHub',
      theme: AppTheme.themeData,
      //primarySwatch: Colors.blue,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}