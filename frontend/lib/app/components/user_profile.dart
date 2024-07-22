import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _socialController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isEditingPassword = false;
  File? _avatar;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatar = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Popola i campi con i dati dell'utente loggato (esempio statico)
    _nameController.text = "Nome Utente";
    _surnameController.text = "Cognome Utente";
    _dobController.text = "01/01/1980";
    _emailController.text = "email@example.com";
    _bioController.text = "Descrizione dell'utente";
    _websiteController.text = "https://www.esempio.com";
    _socialController.text = "https://www.twitter.com/esempio";
    _locationController.text = "Indirizzo Utente";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profilo Utente'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _avatar != null ? FileImage(_avatar!) : AssetImage('images/user_avatar.png'),
                      child: _avatar == null
                          ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blue[50],
                    labelText: 'Nome',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
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
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blue[50],
                    labelText: 'Cognome',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
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
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blue[50],
                    labelText: 'Data di Nascita',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
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
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blue[50],
                    labelText: 'Indirizzo Email',
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
                  readOnly: true,
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                _isEditingPassword = !_isEditingPassword;
                              });
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
                        obscureText: true,
                        readOnly: !_isEditingPassword,
                        validator: (value) {
                          if (_isEditingPassword && (value == null || value.isEmpty)) {
                            return 'Per favore inserisci una password';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                if (_isEditingPassword)
                  const SizedBox(height: 16.0),
                if (_isEditingPassword)
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blue[50],
                      labelText: 'Conferma Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      labelStyle: const TextStyle(color: Colors.blue),
                      hintStyle: const TextStyle(color: Colors.blueGrey),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (_isEditingPassword && value != _passwordController.text) {
                        return 'Le password non corrispondono';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blue[50],
                    labelText: 'Short Bio',
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
                      return 'Per favore inserisci una breve descrizione';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _websiteController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blue[50],
                    labelText: 'Sito Web (facoltativo)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.link, color: Colors.blue),
                    labelStyle: const TextStyle(color: Colors.blue),
                    hintStyle: const TextStyle(color: Colors.blueGrey),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _socialController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blue[50],
                    labelText: 'Link ai Social (facoltativo)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.share, color: Colors.blue),
                    labelStyle: const TextStyle(color: Colors.blue),
                    hintStyle: const TextStyle(color: Colors.blueGrey),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blue[50],
                    labelText: 'Posizione Geografica',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
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
                      return 'Per favore inserisci la tua posizione geografica';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Logica per salvare il profilo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profilo salvato con successo!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Colore blu per il bottone
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Salva Profilo',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}