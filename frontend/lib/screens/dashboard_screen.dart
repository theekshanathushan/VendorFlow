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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.inventory_2_rounded),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
              },
            ),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildKanbanBoard(context, orders, ref);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateOrderScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No orders yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the button below to create one.",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanBoard(BuildContext context, List<Order> orders, WidgetRef ref) {
    final newOrders = orders.where((o) => o.status == 'NEW').toList();
    final paidOrders = orders.where((o) => o.status == 'PAID').toList();
    final shippedOrders = orders.where((o) => o.status == 'SHIPPED').toList();
    final deliveredOrders = orders.where((o) => o.status == 'DELIVERED').toList();

    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildColumn(context, 'NEW', newOrders, ref, Colors.blue),
        const SizedBox(width: 16),
        _buildColumn(context, 'PAID', paidOrders, ref, Colors.green),
        const SizedBox(width: 16),
        _buildColumn(context, 'SHIPPED', shippedOrders, ref, Colors.orange),
        const SizedBox(width: 16),
        _buildColumn(context, 'DELIVERED', deliveredOrders, ref, Colors.purple),
      ],
    );
  }

  Widget _buildColumn(BuildContext context, String title, List<Order> orders, WidgetRef ref, MaterialColor accentColor) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: accentColor.shade100, width: 2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: accentColor.shade700),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: accentColor.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${orders.length}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: accentColor.shade700),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Color(0xFF14B8A6), fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text('${order.items.length} items', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    ),
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
