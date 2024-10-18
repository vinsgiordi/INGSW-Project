import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../../../services/storage_service.dart';
import '../../../../../data/provider/auction_provider.dart';
import '../../../category/categories.dart';

class SilentAuctionPage extends StatefulWidget {
  const SilentAuctionPage({Key? key}) : super(key: key);

  @override
  _SilentAuctionPageState createState() => _SilentAuctionPageState();
}

class _SilentAuctionPageState extends State<SilentAuctionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(); // Aggiunto il controller per il prezzo
  DateTime? _selectedDate;
  int _selectedCategoryId = 1; // ID predefinito per la categoria
  List<File> _images = [];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _endDateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  // Funzione per creare un'asta silenziosa
  Future<void> _createSilentAuction(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Ottieni il token
        String? token = await StorageService().getAccessToken();

        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token non trovato, effettua il login.')),
          );
          return;
        }

        // Dati da inviare per l'asta silenziosa
        Map<String, dynamic> auctionData = {
          'titolo': _titleController.text,
          'descrizione': _descriptionController.text,
          'categoria_id': _selectedCategoryId,
          'tipo': 'silenziosa',
          'stato': 'attiva', // Imposta lo stato come attiva
          'data_scadenza': _selectedDate?.toIso8601String(), // Data di scadenza selezionata
          'prezzo_iniziale': double.parse(_priceController.text), // Usare il valore del prezzo inserito
        };

        // Logica per inviare l'asta silenziosa tramite provider
        await Provider.of<AuctionProvider>(context, listen: false).createAuction(
          token,
          auctionData,
          _images.isNotEmpty ? _images[0].path : null, // Invia immagine solo se presente
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asta silenziosa creata con successo!')),
        );

        Navigator.pop(context); // Torna indietro alla schermata precedente
      } catch (e) {
        print("Errore: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nella creazione dell\'asta silenziosa')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asta Silenziosa'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Titolo',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.title, color: Colors.blue),
                          labelStyle: const TextStyle(color: Colors.blue),
                          hintStyle: const TextStyle(color: Colors.blueGrey),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per favore inserisci un titolo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Descrizione',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.description, color: Colors.blue),
                          labelStyle: const TextStyle(color: Colors.blue),
                          hintStyle: const TextStyle(color: Colors.blueGrey),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per favore inserisci una descrizione';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _priceController, // Aggiunto campo per il prezzo
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Prezzo Iniziale (€)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.attach_money, color: Colors.blue),
                          labelStyle: const TextStyle(color: Colors.blue),
                          hintStyle: const TextStyle(color: Colors.blueGrey),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey),
                          ),
                        ),
                        keyboardType: TextInputType.number, // Il campo accetta solo numeri
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per favore inserisci un prezzo iniziale';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _endDateController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Data di Scadenza',
                          border: const OutlineInputBorder(),
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today, color: Colors.blue),
                            onPressed: () {
                              _selectDate(context);
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
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per favore seleziona una data di scadenza';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Categoria',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.category, color: Colors.blue),
                          labelStyle: const TextStyle(color: Colors.blue),
                          hintStyle: const TextStyle(color: Colors.blueGrey),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey),
                          ),
                        ),
                        items: CategoriesPage.categories.asMap().entries.map((entry) {
                          int index = entry.key;
                          var category = entry.value;
                          return DropdownMenuItem<int>(
                            value: index + 1, // ID della categoria
                            child: Text(category['name']),
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedCategoryId = value ?? 1; // Imposta un ID predefinito
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Per favore seleziona una categoria';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30.0),
                      ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Aggiungi Immagine',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Wrap(
                        spacing: 10,
                        children: _images.map((image) {
                          return Stack(
                            children: [
                              Image.file(image, width: 100, height: 100, fit: BoxFit.cover),
                              Positioned(
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _images.remove(image);
                                    });
                                  },
                                  child: const Icon(Icons.remove_circle, color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30.0),
                      ElevatedButton(
                        onPressed: () => _createSilentAuction(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Crea Asta',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
