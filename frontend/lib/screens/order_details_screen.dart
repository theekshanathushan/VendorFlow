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
      appBar: AppBar(title: const Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                          child: const Icon(Icons.person, color: Color(0xFF6366F1)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.customerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              const SizedBox(height: 4),
                              Text(order.customerPhone, style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: order.status == 'NEW' ? Colors.blue.shade100 : (order.status == 'PAID' ? Colors.green.shade100 : Colors.purple.shade100),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: order.status == 'NEW' ? Colors.blue.shade700 : (order.status == 'PAID' ? Colors.green.shade700 : Colors.purple.shade700),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 12),
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                            child: Center(child: Text('x${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold))),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500))),
                          Text('\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14B8A6))),
                        ],
                      ),
                    )),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
                        Text('\$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (order.status == 'NEW') 
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as PAID (Deduct Stock)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF14B8A6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ref.read(ordersProvider.notifier).updateOrderStatus(order.id!, 'PAID');
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Send Invoice via WhatsApp'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _sendWhatsAppInvoice(context),
            )
          ],
        ),
      ),
    );
  }
}
