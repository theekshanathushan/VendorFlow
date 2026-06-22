import 'package:dio/dio.dart';
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    // 10.0.2.2 is localhost for Android Emulator. Use localhost for iOS/Web.
    baseUrl: 'http://10.0.2.2:8080/api', 
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // Products
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      List<dynamic> data = response.data;
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await _dio.post('/products', data: product.toJson());
      return Product.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  // Orders
  Future<List<Order>> getOrders() async {
    try {
      final response = await _dio.get('/orders');
      List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<Order> createOrder(Order order) async {
    try {
      final response = await _dio.post('/orders', data: order.toJson());
      return Order.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<Order> updateOrderStatus(String id, String status) async {
    try {
      final response = await _dio.put('/orders/$id/status', data: {'status': status});
      return Order.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // AI Mock
  Future<Map<String, String>> generateCaption() async {
    try {
      final response = await _dio.post('/ai/generate-caption');
      return {
        'caption': response.data['caption'],
        'keywords': response.data['keywords'],
      };
    } catch (e) {
      throw Exception('Failed to generate caption: $e');
    }
  }
}
