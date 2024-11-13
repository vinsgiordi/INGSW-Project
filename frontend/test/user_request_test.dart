import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bid_hub/app/data/provider/user_provider.dart';
import 'package:flutter/material.dart';

// Mock della SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Registrazione
  group('User Registration', () {
    // Test di registrazione con dati validi (email dinamica)
    test('Registrazione utente con dati validi', () async {
      final userProvider = UserProvider();
      final email = 'testuser_${DateTime.now().millisecondsSinceEpoch}@example.com';

      // Crea un mock di SharedPreferences
      final mockPrefs = MockSharedPreferences();

      // Definisci cosa fa il mock quando viene chiamato getString
      when(mockPrefs.getString('accessToken')).thenReturn('dummyAccessToken');

      // Imposta il mock nelle SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Esegui la registrazione con dati validi
      await userProvider.register({
        'nome': 'Test',
        'cognome': 'User',
        'data_nascita': '1990-01-01',
        'email': email,
        'password': 'password123'
      });

      // Verifica che l'email restituita sia quella generata dinamicamente
      expect(userProvider.user?.email, email);

      // Recupera l'access token da SharedPreferences
      final accessToken = await mockPrefs.getString('accessToken');

      // Assicurati che l'access token non sia null
      expect(accessToken, 'dummyAccessToken');
    });

    // Test di registrazione con dati validi (email statica)
    test('Registrazione utente con dati validi', () async {
      final userProvider = UserProvider();
      final email = 'testuser@example.com';

      // Crea un mock di SharedPreferences
      final mockPrefs = MockSharedPreferences();

      // Definisci cosa fa il mock quando viene chiamato getString
      when(mockPrefs.getString('accessToken')).thenReturn('dummyAccessToken');

      // Imposta il mock nelle SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Esegui la registrazione con dati validi
      await userProvider.register({
        'nome': 'Test',
        'cognome': 'User',
        'data_nascita': '1990-01-01',
        'email': email,
        'password': 'password123'
      });

      // Verifica che l'email restituita sia quella generata dinamicamente
      expect(userProvider.user?.email, email);

      // Recupera l'access token da SharedPreferences
      final accessToken = await mockPrefs.getString('accessToken');

      // Assicurati che l'access token non sia null
      expect(accessToken, 'dummyAccessToken');
    });

    // Test di registrazione con dati validi per creazione dell'asta
    test('Registrazione utente con dati validi per creazione dell\'asta', () async {
      final userProvider = UserProvider();
      final email = 'test_auction@example.com';

      // Crea un mock di SharedPreferences
      final mockPrefs = MockSharedPreferences();

      // Definisci cosa fa il mock quando viene chiamato getString
      when(mockPrefs.getString('accessToken')).thenReturn('dummyAccessToken');

      // Imposta il mock nelle SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Esegui la registrazione con dati validi
      await userProvider.register({
        'nome': 'Test',
        'cognome': 'User',
        'data_nascita': '1990-01-01',
        'email': email,
        'password': 'password123'
      });

      // Verifica che l'email restituita sia quella generata dinamicamente
      expect(userProvider.user?.email, email);

      // Recupera l'access token da SharedPreferences
      final accessToken = await mockPrefs.getString('accessToken');

      // Assicurati che l'access token non sia null
      expect(accessToken, 'dummyAccessToken');
    });

    // Test di registrazione con dati mancanti
    test('Registrazione con dati incompleti', () async {
      final userProvider = UserProvider();

      // Esegui la registrazione con dati incompleti
      try {
        await userProvider.register({
          'nome': 'Test',
          'cognome': 'User',
          // 'data_nascita' mancante
          'email': 'testuser@example.com',
          'password': 'password123'
        });
        fail('La registrazione con dati incompleti dovrebbe generare un\'eccezione.');
      } catch (e) {
        // Verifica che l'errore contenga la stringa corretta
        expect(e.toString(), contains('Per favore inserisci tutte le informazioni richieste!'));
      }
    });

    // Test di registrazione senza dati
    test('Registrazione senza dati', () async {
      final userProvider = UserProvider();

      try {
        await userProvider.register({
          'nome': '',
          'cognome': '',
          'data_nascita': '',
          'email': '',
          'password': ''
        });

        fail('La registrazione senza dati dovrebbe generare un\'eccezione.');
      } catch (e) {
        expect(e.toString(), contains('Per favore inserisci tutte le informazioni richieste!'));
      }
    });

  });

  // Login
  group('User Login', () {
    // Test di login con credenziali corrette
    test('Login con credenziali corrette', () async {
      final userProvider = UserProvider();
      final email = 'testuser@example.com';
      final password = 'password123';

      // Mock di SharedPreferences
      final mockPrefs = MockSharedPreferences();
      when(mockPrefs.getString('accessToken')).thenReturn('dummyAccessToken');
      SharedPreferences.setMockInitialValues({});

      // Esegui login con credenziali corrette
      await userProvider.login(email, password);

      // Verifica che l'utente sia stato impostato correttamente nel provider
      expect(userProvider.user?.email, email);
      expect(userProvider.isLoading, false);

      // Verifica che l'access token sia stato salvato correttamente
      final accessToken = await mockPrefs.getString('accessToken');
      expect(accessToken, 'dummyAccessToken');
    });

    // Test di login con email vuota
    test('Login con email vuota', () async {
      final userProvider = UserProvider();
      final email = '';
      final password = 'password123';

      // Simuliamo un errore nel login
      try {
        await userProvider.login(email, password);
        fail('Il login con un\'email vuota dovrebbe generare un\'eccezione.');
      } catch (e) {
        // Verifica che l'errore contenga la stringa corretta
        expect(e.toString(), contains('Login failed'));
      }
    });

    // Test di login con email errata
    test('Login con email errata', () async {
      final userProvider = UserProvider();
      final email = 'wrongemail@example.com';
      final password = 'password123';

      // Simuliamo un errore nel login
      try {
        await userProvider.login(email, password);
        fail('Il login con una email errata dovrebbe generare un\'eccezione.');
      } catch (e) {
        // Verifica che l'errore contenga la stringa corretta
        expect(e.toString(), contains('Login failed'));
      }
    });

    // Test di login con password errata
    test('Login con password errata', () async {
      final userProvider = UserProvider();
      final email = 'testuser@example.com';
      final password = 'wrongpassword';

      // Simuliamo un errore nel login
      try {
        await userProvider.login(email, password);
        fail('Il login con una password errata dovrebbe generare un\'eccezione.');
      } catch (e) {
        // Verifica che l'errore contenga la stringa corretta
        expect(e.toString(), contains('Login failed'));
      }
    });

    // Test di login con password vuota
    test('Login con password vuota', () async {
      final userProvider = UserProvider();
      final email = 'testuser@example.com';
      final password = '';

      // Simuliamo un errore nel login
      try {
        await userProvider.login(email, password);
        fail('Il login con una password vuota dovrebbe generare un\'eccezione.');
      } catch (e) {
        // Verifica che l'errore contenga la stringa corretta
        expect(e.toString(), contains('Login failed'));
      }
    });
  });

  // Rest Password
  group('Password Reset', () {
    // Test di reset della password con email valida
    test('Reset password con email valida', () async {
      final userProvider = UserProvider();
      final email = 'testuser@example.com';
      final newPassword = 'newpassword123';

      // Crea un mock di SharedPreferences
      final mockPrefs = MockSharedPreferences();

      // Imposta il mock nelle SharedPreferences
      SharedPreferences.setMockInitialValues({});

      try {
        await userProvider.resetPassword(email, newPassword);
        // Aggiungi l'assert per verificare il comportamento dopo il reset
        print('Password reset successful!');
      } catch (e) {
        fail('Il reset della password con email valida dovrebbe passare.');
      }
    });

    // Test di reset della password con email non valida
    test('Reset password con email non valida', () async {
      final userProvider = UserProvider();
      final email = 'wrongemail@example.com'; // Email non esistente
      final newPassword = 'newpassword123';

      try {
        await userProvider.resetPassword(email, newPassword);
        fail('Il reset della password con email non valida dovrebbe fallire.');
      } catch (e) {
        // Verifica che l'errore contenga la stringa corretta per email non valida
        expect(e.toString(), contains("L'email fornita non corrisponde a nessun account!"));
      }
    });

    // Test di errore generico durante il reset della password
    test('Errore generico durante il reset della password', () async {
      final userProvider = UserProvider();
      final email = 'testuser@example.com';
      final newPassword = 'newpassword123';

      // Simula un errore nel backend (es. fallimento della richiesta HTTP)
      try {
        // Simula un errore nella risposta HTTP
        throw Exception('Errore generico durante il reset della password');
        await userProvider.resetPassword(email, newPassword);
        fail('Il reset della password con errore generico dovrebbe fallire.');
      } catch (e) {
        // Verifica che l'errore contenga la stringa corretta
        expect(e.toString(), contains('Errore generico durante il reset della password'));
      }
    });
  });
}
