import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/bottom_navbar.dart';
import '../../../components/product_detail.dart';
import '../../../data/provider/search_provider.dart'; // Usa il SearchProvider per la ricerca
import '../../../data/provider/category_provider.dart'; // Importiamo il CategoryProvider
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  String _selectedCategory = ''; // Categoria ID selezionata
  String _selectedCategoryId = ''; // Categoria ID selezionata
  String _token = '';

  @override
  void initState() {
    super.initState();
    _loadToken();

    // Utilizza addPostFrameCallback per eseguire operazioni dopo il primo build completo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCategories(); // Recuperiamo le categorie
    });
  }

  // Funzione per caricare il token salvato nelle SharedPreferences
  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    setState(() {
      _token = token ?? '';
    });
  }

  // Funzione per recuperare le categorie utilizzando il provider
  Future<void> _fetchCategories() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    await categoryProvider.fetchRecommendedCategories(); // Recupera le categorie
  }

  // Funzione per eseguire la ricerca basata su query e categoria
  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    await Provider.of<SearchProvider>(context, listen: false).performSearch(
      _token,
      query: query,
      categoryId: _selectedCategoryId.isEmpty ? '' : _selectedCategoryId,
    );
  }

  // Funzione per selezionare una categoria
  void _selectCategory(String category, String categoryId) {
    setState(() {
      _selectedCategory = category;
      _selectedCategoryId = categoryId; // Imposta l'ID della categoria selezionata
      _searchController.clear(); // Pulire la barra di ricerca quando si seleziona una nuova categoria
    });

    // Esegui la ricerca per categoria selezionata
    _performSearch('');
  }

  // Funzione per rimuovere il filtro di categoria
  void _clearCategoryFilter() {
    setState(() {
      _selectedCategory = '';
      _selectedCategoryId = ''; // Reset della categoria selezionata
      _searchController.clear(); // Pulisci anche il campo di ricerca
    });
    _performSearch(''); // Ricerca senza filtro
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context); // Usa il SearchProvider per la ricerca
    final categoryProvider = Provider.of<CategoryProvider>(context); // Accedi al CategoryProvider

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 42.0), // Ridotto il padding per la barra di ricerca
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: (value) {
                      _performSearch(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cerca',
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon: _isSearching
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch(''); // Ricerca vuota per ripristinare i risultati
                        },
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.black), // Bordo nero
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.black), // Bordo nero durante il focus
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    style: const TextStyle(color: Colors.black),
                    cursorColor: Colors.black, // Colore nero per il cursore
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, color: Colors.black),
                  onSelected: (String value) {
                    // Trova l'ID della categoria selezionata
                    String categoryId = categoryProvider.categories
                        .firstWhere((category) => category.nome == value)
                        .id
                        .toString();
                    _selectCategory(value, categoryId); // Passa il nome e l'id della categoria
                  },
                  itemBuilder: (BuildContext context) {
                    return categoryProvider.categories.map<PopupMenuItem<String>>((category) {
                      return PopupMenuItem<String>(
                        value: category.nome,
                        child: Text(category.nome),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
          if (_selectedCategory.isNotEmpty) // Mostra il messaggio solo se c'è una categoria selezionata
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0), // Ridotto il padding verticale
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Categoria selezionata: $_selectedCategory',
                      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearCategoryFilter,
                    child: const Text(
                      'Rimuovi filtro',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 5), // Margine ridotto tra le sezioni
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                if (searchProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!_isSearching && _selectedCategory.isEmpty) {
                  return const Center(
                    child: Text(
                      'Seleziona una categoria o cerca un prodotto',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  );
                }

                if (searchProvider.searchResults.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Nessun risultato trovato.',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: searchProvider.searchResults.length,
                  itemBuilder: (context, index) {
                    final auction = searchProvider.searchResults[index];
                    return ListTile(
                      title: Text(auction.productName ?? ''),
                      subtitle: Text(auction.productDescription ?? ''),
                      onTap: () {
                        // Navigazione verso la pagina dei dettagli del prodotto
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(auctionId: auction.id), // Passa l'id dell'asta
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 2),
    );
  }
}
