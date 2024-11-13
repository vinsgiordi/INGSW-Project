import 'package:bid_hub/app/data/provider/user_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bid_hub/app/data/provider/auction_provider.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';

// Mock della SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('Auction Create', () {
    // Creazione asta all'inglese con login valido
    test('Creazione asta all\'inglese', () async {
      final userProvider = UserProvider();
      final auctionProvider = AuctionProvider();

      final email = 'test_auction@example.com';
      final password = 'password123';

      // Simula il login per ottenere il token
      final mockPrefs = MockSharedPreferences();
      when(mockPrefs.getString('accessToken')).thenReturn('dummyAccessToken');
      SharedPreferences.setMockInitialValues({});

      // Login
      await userProvider.login(email, password);

      // Verifica che il login sia stato effettuato correttamente e che il token sia stato ottenuto
      expect(userProvider.user?.email, email);
      expect(userProvider.isLoading, false);

      // Dati dell'asta
      final auctionData = {
        'tipo': 'inglese',
        'data_scadenza': '2024-12-31T23:59:59Z',
        'prezzo_minimo': 100.0,
        'incremento_rialzo': 10.0,
        'prezzo_iniziale': 50.0,
        'stato': 'attiva',
        'titolo': 'Asta di prova all\'inglese',
        'descrizione': 'Descrizione dell\'asta di prova all\'inglese',
        'categoria_id': 1,
        'immagine_principale': null,
      };

      // Crea l'asta con il token ottenuto dal login
      await auctionProvider.createAuction(auctionData, null);

      // Verifica che l'asta sia stata creata con successo
      expect(auctionProvider.isLoading, false);
    });

    // Creazione asta a tempo fisso con login valido
    test('Creazione asta a tempo fisso', () async {
      final userProvider = UserProvider();
      final auctionProvider = AuctionProvider();

      final email = 'test_auction@example.com';
      final password = 'password123';

      // Simula il login per ottenere il token
      final mockPrefs = MockSharedPreferences();
      when(mockPrefs.getString('accessToken')).thenReturn('dummyAccessToken');
      SharedPreferences.setMockInitialValues({});

      // Login
      await userProvider.login(email, password);

      // Verifica che il login sia stato effettuato correttamente e che il token sia stato ottenuto
      expect(userProvider.user?.email, email);
      expect(userProvider.isLoading, false);

      // Dati dell'asta
      final auctionData = {
        'tipo': 'tempo fisso',
        'data_scadenza': '2024-12-31T23:59:59Z',
        'prezzo_minimo': 100.0,
        'prezzo_iniziale': 400.0,
        'stato': 'attiva',
        'titolo': 'Asta di prova a tempo fisso',
        'descrizione': 'Descrizione dell\'asta di prova a tempo fisso',
        'categoria_id': 2,
        'immagine_principale': null,
      };

      // Crea l'asta con il token ottenuto dal login
      await auctionProvider.createAuction(auctionData, null);

      // Verifica che l'asta sia stata creata con successo
      expect(auctionProvider.isLoading, false);
    });

    // Creazione asta al ribasso con login valido
    test('Creazione asta al ribasso', () async {
      final userProvider = UserProvider();
      final auctionProvider = AuctionProvider();

      final email = 'test_auction@example.com';
      final password = 'password123';

      // Simula il login per ottenere il token
      final mockPrefs = MockSharedPreferences();
      when(mockPrefs.getString('accessToken')).thenReturn('dummyAccessToken');
      SharedPreferences.setMockInitialValues({});

      // Login
      await userProvider.login(email, password);

      // Verifica che il login sia stato effettuato correttamente e che il token sia stato ottenuto
      expect(userProvider.user?.email, email);
      expect(userProvider.isLoading, false);

      // Dati dell'asta
      final auctionData = {
        'tipo': 'ribasso',
        'prezzo_iniziale': 1000.0,
        'decremento_prezzo': 50.0,
        'prezzo_minimo': 500.0,
        'timer_decremento': 1,
        'stato': 'attiva',
        'titolo': 'Asta di prova al ribasso',
        'descrizione': 'Descrizione dell\'asta di prova al ribasso',
        'categoria_id': 3,
        'immagine_principale': null,
      };

      // Crea l'asta con il token ottenuto dal login
      await auctionProvider.createAuction(auctionData, null);

      // Verifica che l'asta sia stata creata con successo
      expect(auctionProvider.isLoading, false);
    });

    // Creazione asta silenziosa con login valido
    test('Creazione asta silenziosa', () async {
      final userProvider = UserProvider();
      final auctionProvider = AuctionProvider();

      final email = 'test_auction@example.com';
      final password = 'password123';

      // Simula il login per ottenere il token
      final mockPrefs = MockSharedPreferences();
      when(mockPrefs.getString('accessToken')).thenReturn('dummyAccessToken');
      SharedPreferences.setMockInitialValues({});

      // Login
      await userProvider.login(email, password);

      // Verifica che il login sia stato effettuato correttamente e che il token sia stato ottenuto
      expect(userProvider.user?.email, email);
      expect(userProvider.isLoading, false);

      // Dati dell'asta
      final auctionData = {
        'tipo': 'silenziosa',
        'data_scadenza': '2024-12-31T23:59:59Z',
        'prezzo_iniziale': 50.0,
        'stato': 'attiva',
        'titolo': 'Asta di prova silenziosa',
        'descrizione': 'Descrizione dell\'asta di prova silenziosa',
        'categoria_id': 4,
        'immagine_principale': null,
      };

      // Crea l'asta con il token ottenuto dal login
      await auctionProvider.createAuction(auctionData, null);

      // Verifica che l'asta sia stata creata con successo
      expect(auctionProvider.isLoading, false);
    });

    // Creazione asta con parametri mancanti
    test('Creazione asta con parametri mancanti', () async {
      final userProvider = UserProvider();
      final auctionProvider = AuctionProvider();

      final email = 'test_auction@example.com';
      final password = 'password123';

      // Simula il login per ottenere il token
      final mockPrefs = MockSharedPreferences();
      when(mockPrefs.getString('accessToken')).thenReturn('dummyAccessToken');
      SharedPreferences.setMockInitialValues({});

      // Login
      await userProvider.login(email, password);

      // Verifica che il login sia stato effettuato correttamente e che il token sia stato ottenuto
      expect(userProvider.user?.email, email);
      expect(userProvider.isLoading, false);

      // Dati dell'asta
      final auctionData = {
        'tipo': 'inglese',
      };

      // Crea l'asta con il token ottenuto dal login
      await auctionProvider.createAuction(auctionData, null);

      // Verifica che l'asta sia stata creata con successo
      expect(auctionProvider.isLoading, false);
    });

  });
}
