import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../../../services/storage_service.dart';
import '../../../../../data/provider/auction_provider.dart';
import '../../../category/categories.dart';

class EnglishAuctionPage extends StatefulWidget {
  const EnglishAuctionPage({super.key});

  @override
  _EnglishAuctionPageState createState() => _EnglishAuctionPageState();
}

class _EnglishAuctionPageState extends State<EnglishAuctionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _bidIncrementController = TextEditingController(text: '10'); // Default 10€
  final TextEditingController _endTimeController = TextEditingController(text: '1'); // Default 1h
  int _selectedCategoryId = 1; // Imposta un ID predefinito unico
  List<File> _images = [];

  // Funzione per gestire l'immagine
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  // Funzione per creare l'asta all'inglese
  Future<void> _createEnglishAuction(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Ottieni il token dall'archiviazione
        String? token = await StorageService().getAccessToken();

        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token non trovato, per favore effettua il login.')),
          );
          return;
        }

        int categoryId = _selectedCategoryId;
        if (categoryId == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categoria non valida, per favore seleziona una categoria.')),
          );
          return;
        }

        // Imposta la data di scadenza basata sull'intervallo di tempo specificato
        DateTime currentTime = DateTime.now();
        int auctionDuration = int.parse(_endTimeController.text); // Intervallo di tempo in ore
        DateTime endTime = currentTime.add(Duration(hours: auctionDuration));
        String formattedEndTime = DateFormat('yyyy-MM-ddTHH:mm:ss').format(endTime);

        // Dati da inviare
        Map<String, dynamic> auctionData = {
          'titolo': _titleController.text,
          'descrizione': _descriptionController.text,
          'prezzo_iniziale': double.parse(_basePriceController.text),
          'incremento_rialzo': double.parse(_bidIncrementController.text),
          'categoria_id': categoryId,
          'tipo': 'inglese',
          'stato': 'attiva',
          'data_scadenza': formattedEndTime,
        };

        print("Dati prima dell'invio: $auctionData");

        // Chiamata API tramite AuctionProvider
        await Provider.of<AuctionProvider>(context, listen: false).createAuction(
          token,
          auctionData,
          _images.isNotEmpty ? _images[0].path : null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asta all\'inglese creata con successo!')),
        );

        Navigator.pop(context);
      } catch (e) {
        print("Errore: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nella creazione dell\'asta all\'inglese')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asta all\'Inglese'),
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
                        controller: _basePriceController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Base d\'asta (€)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.euro, color: Colors.blue),
                          labelStyle: const TextStyle(color: Colors.blue),
                          hintStyle: const TextStyle(color: Colors.blueGrey),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per favore inserisci una base d\'asta';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _bidIncrementController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Soglia di Rialzo (€)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.add, color: Colors.blue),
                          labelStyle: const TextStyle(color: Colors.blue),
                          hintStyle: const TextStyle(color: Colors.blueGrey),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per favore inserisci una soglia di rialzo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _endTimeController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Intervallo di Tempo (ore)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.timer, color: Colors.blue),
                          labelStyle: const TextStyle(color: Colors.blue),
                          hintStyle: const TextStyle(color: Colors.blueGrey),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty || int.tryParse(value) == null) {
                            return 'Per favore inserisci un intervallo di tempo valido in ore';
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
                            value: index + 1,
                            child: Text(category['name']),
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedCategoryId = value ?? 1;
                          });
                        },
                        validator: (value) {
                          if (value == null || value == 0) {
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
                        onPressed: () => _createEnglishAuction(context),
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
