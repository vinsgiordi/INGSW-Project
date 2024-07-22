import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> unpaidOrders = [];
  List<String> paidOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Qui potresti caricare gli ordini dal backend
    fetchOrders();
  }

  void fetchOrders() {
    // Simulazione dei dati
    unpaidOrders = ['Ordine 1', 'Ordine 2'];
    paidOrders = ['Ordine 3'];
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordini'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue, // Colore del selettore
          labelColor: Colors.blue, // Colore del testo selezionato
          unselectedLabelColor: Colors.blueGrey, // Colore del testo non selezionato
          tabs: const [
            Tab(text: 'Non pagato'),
            Tab(text: 'Pagato'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrdersList(orders: unpaidOrders, emptyMessage: 'Ancora nessun ordine non pagato.'),
          OrdersList(orders: paidOrders, emptyMessage: 'Ancora nessun ordine pagato.'),
        ],
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final List<String> orders;
  final String emptyMessage;

  const OrdersList({super.key, required this.orders, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/donna_che_ordina.jpg'), // Aggiungi la tua immagine
            const SizedBox(height: 20),
            Text(emptyMessage),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logica per ricaricare gli ordini
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Colore blu per il bottone
              ),
              child: const Text('Ricarica'),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(orders[index]),
          );
        },
      );
    }
  }
}