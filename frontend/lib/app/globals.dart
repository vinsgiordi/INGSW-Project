import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData themeData = ThemeData(
    primarySwatch: Colors.blue,
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue), // Colore blu quando il campo è attivo
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueGrey), // Colore blu/grigio quando il campo è disabilitato
      ),
      labelStyle: TextStyle(color: Colors.blue), // Colore del testo della label
      prefixIconColor: Colors.blue,  // Colore dell'icona del prefisso
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.blue, // Imposta il colore del cursore
      selectionColor: Colors.blue[200], // Colore della selezione
      selectionHandleColor: Colors.blue, // Colore del manico della selezione
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.blue;
        }
        return Colors.white; // colore quando non selezionata
      }),
    ),
  );
}