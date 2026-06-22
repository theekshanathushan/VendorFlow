import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import 'inventory_screen.dart';
import 'create_order_screen.dart';
import 'order_details_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VendorFlow Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
            },
          )
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet. Tap + to create one."));
          }
          return _buildKanbanBoard(context, orders, ref);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateOrderScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildKanbanBoard(BuildContext context, List<Order> orders, WidgetRef ref) {
    // Group orders by status
    final newOrders = orders.where((o) => o.status == 'NEW').toList();
    final paidOrders = orders.where((o) => o.status == 'PAID').toList();
    final shippedOrders = orders.where((o) => o.status == 'SHIPPED').toList();
    final deliveredOrders = orders.where((o) => o.status == 'DELIVERED').toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColumn(context, 'NEW', newOrders, ref),
          _buildColumn(context, 'PAID', paidOrders, ref),
          _buildColumn(context, 'SHIPPED', shippedOrders, ref),
          _buildColumn(context, 'DELIVERED', deliveredOrders, ref),
        ],
      ),
    );
  }

  Widget _buildColumn(BuildContext context, String title, List<Order> orders, WidgetRef ref) {
    return Container(
      width: 250,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(order.customerName),
                    subtitle: Text('\$${order.totalAmount.toStringAsFixed(2)}'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
