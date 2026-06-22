import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getProducts();
});
