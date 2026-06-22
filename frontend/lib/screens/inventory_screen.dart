import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import 'add_product_screen.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text("No products in inventory."));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isLowStock = product.stockCount < 5;
              return ListTile(
                title: Text(product.name),
                subtitle: Text('\$${product.price} - Stock: ${product.stockCount}'),
                trailing: isLowStock 
                    ? const Icon(Icons.warning, color: Colors.red) 
                    : const Icon(Icons.check_circle, color: Colors.green),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
