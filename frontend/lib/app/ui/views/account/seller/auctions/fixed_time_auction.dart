import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../../../../services/storage_service.dart';
import '../../../../../data/provider/auction_provider.dart';
import '../../../category/categories.dart';

class FixedTimeAuctionPage extends StatefulWidget {
  const FixedTimeAuctionPage({Key? key}) : super(key: key);

  @override
  _FixedTimeAuctionPageState createState() => _FixedTimeAuctionPageState();
}

class _FixedTimeAuctionPageState extends State<FixedTimeAuctionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _initialPriceController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _selectedCategoryId = CategoriesPage.categories[0]['id']; // Seleziona il primo ID categoria come predefinito
  List<File> _images = [];

  final StorageService _storageService = StorageService();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  // Seleziona la data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _updateEndDateField();
      });
    }
  }

  // Seleziona l'ora
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
        _updateEndDateField();
      });
    }
  }

  // Aggiorna il campo del testo per mostrare la data e ora selezionate
  void _updateEndDateField() {
    if (_selectedDate != null && _selectedTime != null) {
      final DateTime combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      _endDateController.text = "${combinedDateTime.day}/${combinedDateTime.month}/${combinedDateTime.year} ${_selectedTime!.format(context)}";
    }
  }

  // Funzione per convertire l'immagine in base64
  String? _imageToBase64() {
    if (_images.isNotEmpty) {
      final bytes = File(_images[0].path).readAsBytesSync();
      return base64Encode(bytes); // Converte in base64
    }
    return null; // Nessuna immagine selezionata
  }

  Future<void> _submitAuction() async {
    if (_formKey.currentState!.validate()) {
      // Combinare la data e l'ora selezionate
      final DateTime auctionEndDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Prepara i dati dell'asta
      final auctionData = {
        'titolo': _titleController.text,
        'descrizione': _descriptionController.text,
        'prezzo_minimo': double.parse(_minPriceController.text),
        'prezzo_iniziale': double.parse(_initialPriceController.text),
        'data_scadenza': auctionEndDate.toIso8601String(),
        'categoria_id': _selectedCategoryId, // Invia l'ID della categoria selezionata
        'tipo': 'tempo fisso',
        'stato': 'attiva',
      };

      // Preleva il provider
      final auctionProvider = Provider.of<AuctionProvider>(context, listen: false);

      // Recupera l'immagine in base64
      String? immagineBase64 = _imageToBase64();

      // Recupera il token dal servizio di storage
      final token = await _storageService.getAccessToken();

      if (token != null) {
        // Invia i dati tramite il provider
        await auctionProvider.createAuction(
          token,  // Usa il token recuperato
          auctionData,
          immagineBase64, // Passa l'immagine se presente
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asta a tempo fisso creata con successo!')),
        );

        // Torna alla pagina precedente
        Navigator.pop(context);
      } else {
        // Mostra un messaggio di errore se il token non è disponibile
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token non disponibile. Effettua il login.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asta a Tempo Fisso'),
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
                          labelText: 'Prezzo di Vendita (iniziale)',
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
                            return 'Per favore inserisci un prezzo di vendita';
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
                        items: CategoriesPage.categories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category['id'],
                            child: Text(category['name']),
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedCategoryId = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Per favore seleziona una categoria';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _endDateController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.blue[50],
                                labelText: 'Data di Scadenza',
                                border: const OutlineInputBorder(),
                                prefixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today, color: Colors.blue),
                                  onPressed: () => _selectDate(context),
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
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _selectTime(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Seleziona Ora',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Colore blu per il bottone
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
                      // Mostra l'anteprima delle immagini selezionate
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
