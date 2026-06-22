import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final Order order;
  const OrderDetailsScreen({super.key, required this.order});

  Future<void> _sendWhatsAppInvoice(BuildContext context) async {
    String invoiceText = 'Hello ${order.customerName},\n\nHere is your order summary:\n';
    for (var item in order.items) {
      invoiceText += '- ${item.productName} (x${item.quantity}) : \$${item.unitPrice * item.quantity}\n';
    }
    invoiceText += '\n*Total: \$${order.totalAmount}*\n\nStatus: ${order.status}\n\nPlease let us know if you have any questions!';
    
    // Remove non-numeric characters from phone number for the URL
    String cleanPhone = order.customerPhone.replaceAll(RegExp(r'\D'), '');
    final Uri url = Uri.parse('whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(invoiceText)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp. Make sure it is installed.')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${order.customerName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Phone: ${order.customerPhone}'),
            const SizedBox(height: 20),
            const Text('Items:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...order.items.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.productName),
              subtitle: Text('Qty: ${item.quantity}'),
              trailing: Text('\$${item.unitPrice * item.quantity}'),
            )),
            const Divider(),
            Text('Total: \$${order.totalAmount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Status: ${order.status}'),
            const SizedBox(height: 20),
            
            // Mark as Paid to trigger Tap-to-Deduct
            if (order.status == 'NEW') 
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  ref.read(ordersProvider.notifier).updateOrderStatus(order.id!, 'PAID');
                  Navigator.pop(context);
                },
                child: const Text('Mark as PAID (Deduct Stock)', style: TextStyle(color: Colors.white)),
              ),

            const SizedBox(height: 20),
            // WhatsApp Invoice Button
            ElevatedButton.icon(
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text('Send Invoice via WhatsApp', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () => _sendWhatsAppInvoice(context),
            )
          ],
        ),
      ),
    );
  }
}
