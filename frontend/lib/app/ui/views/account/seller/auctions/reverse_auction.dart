import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../../services/storage_service.dart';
import '../../../../../data/provider/auction_provider.dart';
import '../../../category/categories.dart';

class ReverseAuctionPage extends StatefulWidget {
  const ReverseAuctionPage({Key? key}) : super(key: key);

  @override
  _ReverseAuctionPageState createState() => _ReverseAuctionPageState();
}

class _ReverseAuctionPageState extends State<ReverseAuctionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _initialPriceController = TextEditingController();
  final TextEditingController _priceDecrementController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _timerController = TextEditingController(text: '1'); // Default 1 ora
  String _selectedCategory = CategoriesPage.categories[0]['id'].toString(); // Assicurati che sia una stringa
  List<File> _images = [];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitAuction() async {
    if (_formKey.currentState!.validate()) {
      // Prepara i dati dell'asta per il backend
      final auctionData = {
        'titolo': _titleController.text,
        'descrizione': _descriptionController.text,
        'prezzo_iniziale': double.parse(_initialPriceController.text),
        'decremento_prezzo': double.parse(_priceDecrementController.text),
        'prezzo_minimo': double.parse(_minPriceController.text),
        'categoria_id': _selectedCategory,
        'tipo': 'ribasso',
        'stato': 'attiva',
        'data_scadenza': DateTime.now().add(Duration(hours: int.parse(_timerController.text))).toIso8601String(),
        'timer_decremento': int.parse(_timerController.text),
      };

      // Recupera il token dallo storage
      String? token = await StorageService().getAccessToken();
      print("Token recuperato: $token");  // Aggiungi un log per vedere se il token è valido

      if (token == null) {
        print("Token non presente o nullo");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token non trovato, per favore effettua il login.')),
        );
        return;
      }

      try {
        // Chiamata API per creare l'asta
        await AuctionProvider().createAuction(token, auctionData, _images.isNotEmpty ? _images[0].path : null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asta al ribasso creata con successo!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        print('Errore durante la creazione dell\'asta: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante la creazione dell\'asta')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asta al Ribasso'),
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
                        controller: _initialPriceController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Prezzo Iniziale (€)',
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
                            return 'Per favore inserisci un prezzo iniziale';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _priceDecrementController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Decremento (€)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.trending_down, color: Colors.blue),
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
                            return 'Per favore inserisci un decremento';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _minPriceController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Prezzo Minimo (segreto)',
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
                            return 'Per favore inserisci un prezzo minimo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _timerController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Timer decremento prezzo (ore)',
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
                          if (value == null || value.isEmpty) {
                            return 'Per favore inserisci un intervallo di tempo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
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
                        items: CategoriesPage.categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['id'].toString(),
                            child: Text(category['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
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
                        onPressed: _submitAuction,
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
