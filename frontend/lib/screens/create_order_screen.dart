import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String customerName = '';
  String customerPhone = '';
  List<OrderItem> selectedItems = [];
  
  Product? selectedProduct;
  int quantity = 1;

  void _addItem() {
    if (selectedProduct == null) return;
    if (selectedProduct!.stockCount < quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Only ${selectedProduct!.stockCount} items in stock for ${selectedProduct!.name}')),
      );
      return;
    }

    setState(() {
      selectedItems.add(OrderItem(
        productId: selectedProduct!.id,
        productName: selectedProduct!.name,
        quantity: quantity,
        unitPrice: selectedProduct!.price,
      ));
      selectedProduct = null;
      quantity = 1;
    });
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate() || selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add items and fill details')));
      return;
    }
    _formKey.currentState!.save();

    double total = selectedItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));
    
    final order = Order(
      customerName: customerName,
      customerPhone: customerPhone,
      items: selectedItems,
      totalAmount: total,
    );

    try {
      final api = ref.read(apiServiceProvider);
      await api.createOrder(order);
      await ref.read(ordersProvider.notifier).fetchOrders();
      if(mounted) {
         Navigator.pop(context);
      }
    } catch (e) {
       if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create order: $e')));
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => customerName = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Customer Phone (WhatsApp)'),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => customerPhone = v!,
              ),
              const Divider(height: 30),
              const Text('Add Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              productsAsync.when(
                data: (products) => Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButton<Product>(
                        value: selectedProduct,
                        hint: const Text('Select Product'),
                        isExpanded: true,
                        items: products.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (Stock: ${p.stockCount})'))).toList(),
                        onChanged: (p) => setState(() => selectedProduct = p),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: '1',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Qty'),
                        onChanged: (v) => quantity = int.tryParse(v) ?? 1,
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.add_circle, color: Colors.blue), onPressed: _addItem)
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error loading products: $e'),
              ),
              const SizedBox(height: 10),
              ...selectedItems.map((item) => ListTile(
                title: Text('${item.productName} x ${item.quantity}'),
                trailing: Text('\$${item.unitPrice * item.quantity}'),
                onLongPress: () {
                  setState(() => selectedItems.remove(item));
                },
              )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitOrder,
                child: const Text('Create Order'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
