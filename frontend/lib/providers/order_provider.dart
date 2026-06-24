import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import 'product_provider.dart';

class OrderListNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    final apiService = ref.watch(apiServiceProvider);
    return apiService.getOrders();
  }

  Future<void> fetchOrders() async {
    state = const AsyncValue.loading();
    try {
      final apiService = ref.read(apiServiceProvider);
      final orders = await apiService.getOrders();
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateOrderStatus(String id, String newStatus) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.updateOrderStatus(id, newStatus);
      await fetchOrders(); // refresh after update
    } catch (e) {
      rethrow;
    }
  }
}

final ordersProvider = AsyncNotifierProvider<OrderListNotifier, List<Order>>(() {
  return OrderListNotifier();
});
