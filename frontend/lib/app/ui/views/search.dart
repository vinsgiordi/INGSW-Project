import 'package:flutter/material.dart';
import '../../components/bottom_navbar.dart';
import 'category/categories.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  String _selectedCategory = 'Tutte le categorie';

  void _performSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    // Placeholder for backend search
    // Future: Send query and selected category to the backend
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
  }

  void _cancelSearch() {
    _searchController.clear();
    _focusNode.unfocus(); // Nasconde la tastiera
    setState(() {
      _isSearching = false;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _clearCategoryFilter() {
    setState(() {
      _selectedCategory = 'Tutte le categorie';
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        // Aggiorna lo stato quando il focus cambia
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(35.0),
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
                      hintText: 'Cerca per marchio, modello, artista...',
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      suffixIcon: _isSearching
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.blue),
                        onPressed: _clearSearch,
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                if (_focusNode.hasFocus)
                  TextButton(
                    onPressed: _cancelSearch,
                    child: const Text('Annulla', style: TextStyle(color: Colors.blue)),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, color: Colors.blue),
                  onSelected: (String value) {
                    _selectCategory(value);
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'Tutte le categorie',
                        child: Text('Tutte le categorie'),
                      ),
                      ...CategoriesPage.categories.map<PopupMenuItem<String>>((Map<String, dynamic> category) {
                        return PopupMenuItem<String>(
                          value: category['name'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                    ];
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Categoria selezionata: $_selectedCategory',
                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_selectedCategory != 'Tutte le categorie')
                  TextButton(
                    onPressed: _clearCategoryFilter,
                    child: const Text('Rimuovi filtro', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          if (_isSearching)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Nessun risultato trovato.',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),

          // Placeholder for displaying search results
          const Expanded(
            child: Center(
              child: Text(
                'Risultati della ricerca verranno visualizzati qui.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),

        ],
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 2),
    );
  }
}
