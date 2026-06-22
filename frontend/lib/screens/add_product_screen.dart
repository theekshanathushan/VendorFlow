import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  double price = 0;
  int stock = 0;
  bool isGenerating = false;

  Future<void> _generateAI() async {
    setState(() => isGenerating = true);
    try {
      final api = ref.read(apiServiceProvider);
      final aiData = await api.generateCaption();
      setState(() {
        description = aiData['caption'] ?? '';
      });
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Caption Generated!')));
      }
    } catch(e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => isGenerating = false);
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final product = Product(id: '', name: name, description: description, price: price, stockCount: stock);
      try {
        final api = ref.read(apiServiceProvider);
        await api.createProduct(product);
        ref.invalidate(productsProvider); // Refresh the list
        if(mounted) {
           Navigator.pop(context);
        }
      } catch(e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => name = v!,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: TextEditingController(text: description),
                      decoration: const InputDecoration(labelText: 'Description (Caption)'),
                      maxLines: 3,
                      onChanged: (v) => description = v,
                      onSaved: (v) => description = v!,
                    ),
                  ),
                  IconButton(
                    icon: isGenerating ? const CircularProgressIndicator() : const Icon(Icons.auto_awesome, color: Colors.purple),
                    onPressed: isGenerating ? null : _generateAI,
                    tooltip: 'Generate AI Caption from Photo',
                  )
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => price = double.parse(v!),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Initial Stock Count'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => stock = int.parse(v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Save Product'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
