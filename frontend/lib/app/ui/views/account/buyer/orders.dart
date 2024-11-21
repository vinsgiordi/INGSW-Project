import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../services/storage_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/provider/order_provider.dart';
import 'checkouts.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOrders();
  }

  void _fetchOrders() async {
    final token = await _storageService.getAccessToken();
    if (token != null) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders(token);
    }
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
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.blueGrey,
          tabs: const [
            Tab(text: 'Non pagato'),
            Tab(text: 'Pagato'),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final unpaidOrders = orderProvider.orders.where((order) => order.stato == 'in elaborazione').toList();
          final paidOrders = orderProvider.orders.where((order) => order.stato == 'pagato').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              OrdersList(
                orders: unpaidOrders,
                emptyMessage: 'Ancora nessun ordine non pagato.',
                onPayPressed: (order) => _openCheckoutPage(order),
              ),
              OrdersList(
                orders: paidOrders,
                emptyMessage: 'Ancora nessun ordine pagato.',
              ),
            ],
          );
        },
      ),
    );
  }

  void _openCheckoutPage(Order order) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CheckoutPage(order: order)),
    );

    if (result == true) {
      _fetchOrders(); // Refresh orders after payment
    }
  }
}

class OrdersList extends StatelessWidget {
  final List<Order> orders;
  final String emptyMessage;
  final Function(Order)? onPayPressed;

  const OrdersList({
    Key? key,
    required this.orders,
    required this.emptyMessage,
    this.onPayPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(emptyMessage),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                final token = await StorageService().getAccessToken();
                if (token != null) orderProvider.fetchOrders(token);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
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
          final order = orders[index];
          final product = order.product;

          return ListTile(
            title: Text(product?.nome ?? "Prodotto Sconosciuto"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Descrizione: ${product?.descrizione ?? "Non disponibile"}"),
                Text("Stato Ordine: ${order.stato}"),
                Text("Totale: €${order.importoTotale.toStringAsFixed(2)}"),
              ],
            ),
            trailing: order.stato == 'in elaborazione' && onPayPressed != null
                ? ElevatedButton(
              onPressed: () => onPayPressed!(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Paga'),
            )
                : null,
          );
        },
      );
    }
  }
}
