import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../data/provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? _avatar;
  Map<String, TextEditingController> _socialControllers = {};

  // Password controllers
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isEditingPassword = false;
  bool _isPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token non trovato, effettuare il login')),
      );
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    // Effettua la richiesta per ottenere i dati utente
    try {
      await userProvider.getUserData(token);
      setState(() {
        if (userProvider.user != null) {
          _nameController.text = userProvider.user!.nome;
          _surnameController.text = userProvider.user!.cognome;
          _dobController.text = userProvider.user!.dataNascita ?? '';
          _emailController.text = userProvider.user!.email;
          _bioController.text = userProvider.user!.shortBio ?? '';
          _websiteController.text = userProvider.user!.sitoWeb ?? '';
          _locationController.text = userProvider.user!.posizioneGeografica ?? '';

          // Gestione social links
          _socialControllers.clear();
          if (userProvider.user!.socialLinks != null) {
            userProvider.user!.socialLinks!.forEach((key, value) {
              _socialControllers[key] = TextEditingController(text: value);
            });
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel caricamento del profilo: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatar = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token non trovato, effettuare il login')),
      );
      return;
    }

    // Prepariamo i dati da aggiornare, inclusi nome, cognome e data di nascita
    final Map<String, dynamic> updatedData = {
      'nome': _nameController.text,
      'cognome': _surnameController.text,
      'data_nascita': _dobController.text,
      'short_bio': _bioController.text,
      'sito_web': _websiteController.text,
      'posizione_geografica': _locationController.text,
      'social_links': _socialControllers.map((key, controller) {
        return MapEntry(key, controller.text);
      }),
    };

    // Aggiungiamo la password solo se è stata modificata
    if (_isEditingPassword && _newPasswordController.text.isNotEmpty && _newPasswordController.text == _confirmPasswordController.text) {
      updatedData['password'] = _newPasswordController.text;
    } else if (_isEditingPassword && _newPasswordController.text != _confirmPasswordController.text) {
      // Se le password non coincidono, mostriamo un errore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le password non coincidono!')),
      );
      return; // Fermiamo l'esecuzione
    }

    try {
      await userProvider.updateUser(token, updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profilo aggiornato con successo!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nell\'aggiornamento del profilo: $e')),
      );
    }
  }

  // Metodo per aggiungere i campi social
  void _addSocialField() async {
    String? selectedSocial = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Seleziona un social'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Facebook');
              },
              child: const Text('Facebook'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Twitter');
              },
              child: const Text('Twitter'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Instagram');
              },
              child: const Text('Instagram'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'LinkedIn');
              },
              child: const Text('LinkedIn'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Altro');
              },
              child: const Text('Altro'),
            ),
          ],
        );
      },
    );

    if (selectedSocial != null) {
      setState(() {
        final socialController = TextEditingController();
        _socialControllers[selectedSocial] = socialController;
      });
    }
  }

  void _removeSocialField(String key) {
    setState(() {
      _socialControllers.remove(key);
    });
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma eliminazione'),
          content: const Text('Sei sicuro di voler eliminare il tuo account? Questa azione non può essere annullata.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProfile();
              },
              child: const Text('Elimina', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token non trovato, effettuare il login')),
      );
      return;
    }

    try {
      await userProvider.deleteUser(token);
      Navigator.of(context).pushReplacementNamed('/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account eliminato con successo.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nell\'eliminazione dell\'account: $e')),
      );
    }
  }

  bool isBase64(String value) {
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return value.length % 4 == 0 && base64Regex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profilo Utente'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.user == null || userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: userProvider.user?.avatar != null
                                ? (isBase64(userProvider.user!.avatar!)
                                ? MemoryImage(base64Decode(userProvider.user!.avatar!))
                                : NetworkImage(userProvider.user!.avatar!) as ImageProvider)
                                : const AssetImage('images/user_avatar.png'),
                          ),
                          const SizedBox(height: 8.0),
                          GestureDetector(
                            onTap: _pickImage, // Chiama la funzione per selezionare un'immagine
                            child: const Text(
                              'Modifica avatar',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    _buildEditableTextField(_nameController, 'Nome', Icons.person),
                    const SizedBox(height: 16.0),
                    _buildEditableTextField(_surnameController, 'Cognome', Icons.person),
                    const SizedBox(height: 16.0),
                    _buildEditableTextField(_dobController, 'Data di Nascita', Icons.calendar_today),
                    const SizedBox(height: 16.0),
                    _buildReadOnlyTextField(_emailController, 'Indirizzo Email', Icons.email),

                    const SizedBox(height: 16.0),
                    _buildPasswordField(),
                    if (_isEditingPassword) ...[
                      const SizedBox(height: 16.0),
                      _buildNewPasswordFields(),
                    ],

                    const SizedBox(height: 16.0),
                    _buildTextField(_bioController, 'Short Bio', Icons.description),
                    const SizedBox(height: 16.0),
                    _buildTextField(_websiteController, 'Sito Web (facoltativo)', Icons.link),

                    const SizedBox(height: 16.0),
                    _buildSocialFields(),

                    const SizedBox(height: 16.0),
                    _buildTextField(_locationController, 'Posizione Geografica', Icons.location_on),

                    const SizedBox(height: 32.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
                    const SizedBox(height: 16.0),
                    Center(
                      child: GestureDetector(
                        onTap: _showDeleteConfirmationDialog,
                        child: const Text(
                          'Elimina Profilo',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _currentPasswordController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue[50],
        labelText: 'Password Attuale',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
        suffixIcon: IconButton(
          icon: _isEditingPassword
              ? Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off)
              : Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            setState(() {
              if (_isEditingPassword) {
                _isPasswordVisible = !_isPasswordVisible;
              } else {
                _isEditingPassword = true;
              }
            });
          },
        ),
      ),
      obscureText: !_isPasswordVisible,
      readOnly: !_isEditingPassword,
    );
  }

  Widget _buildNewPasswordFields() {
    return Column(
      children: [
        TextFormField(
          controller: _newPasswordController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.blue[50],
            labelText: 'Nuova Password',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock, color: Colors.blue),
            suffixIcon: IconButton(
              icon: Icon(_isNewPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _isNewPasswordVisible = !_isNewPasswordVisible;
                });
              },
            ),
          ),
          obscureText: !_isNewPasswordVisible,
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.blue[50],
            labelText: 'Conferma Nuova Password',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock, color: Colors.blue),
            suffixIcon: IconButton(
              icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
          ),
          obscureText: !_isConfirmPasswordVisible,
        ),
      ],
    );
  }

  Widget _buildSocialFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link ai Social (facoltativo)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 8.0),
        Column(
          children: _socialControllers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue[50],
                        prefixIcon: const Icon(Icons.link, color: Colors.blue),
                        labelText: entry.key,
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _removeSocialField(entry.key),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        GestureDetector(
          onTap: _addSocialField,
          child: Row(
            children: const [
              Icon(Icons.add, color: Colors.blue),
              SizedBox(width: 8.0),
              Text(
                'Aggiungi Social',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue[50],
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, color: Colors.blue),
      ),
      maxLines: label == 'Short Bio' ? 3 : 1,
    );
  }

  Widget _buildEditableTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue[50],
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, color: Colors.blue),
      ),
    );
  }

  Widget _buildReadOnlyTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue[50],
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, color: Colors.blue),
      ),
      readOnly: true,
    );
  }
}
