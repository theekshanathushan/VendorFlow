import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderListNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final ApiService _apiService;

  OrderListNotifier(this._apiService) : super(const AsyncValue.loading()) {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      state = const AsyncValue.loading();
      final orders = await _apiService.getOrders();
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateOrderStatus(String id, String newStatus) async {
    try {
      await _apiService.updateOrderStatus(id, newStatus);
      await fetchOrders(); // refresh after update
    } catch (e) {
      // Handle error, maybe show a snackbar in the UI
      rethrow;
    }
  }
}

final ordersProvider = StateNotifierProvider<OrderListNotifier, AsyncValue<List<Order>>>((ref) {
  final api = ref.watch(apiServiceProvider);
  return OrderListNotifier(api);
});
